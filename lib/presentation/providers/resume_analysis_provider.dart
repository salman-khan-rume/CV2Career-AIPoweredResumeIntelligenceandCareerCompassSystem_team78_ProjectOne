import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_result.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/pdf_service.dart';
import 'auth_provider.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService.instance);
final pdfServiceProvider = Provider<PdfService>((ref) => PdfService.instance);

enum AnalysisPhase { idle, uploading, parsing, analysing, done, error }

class ResumeAnalysisState {
  final AnalysisPhase phase;
  final AnalysisResult? result;
  final String? errorMessage;

  const ResumeAnalysisState({
    this.phase = AnalysisPhase.idle,
    this.result,
    this.errorMessage,
  });

  ResumeAnalysisState copyWith({
    AnalysisPhase? phase,
    AnalysisResult? result,
    String? errorMessage,
  }) {
    return ResumeAnalysisState(
      phase: phase ?? this.phase,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class ResumeAnalysisNotifier extends Notifier<ResumeAnalysisState> {
  @override
  ResumeAnalysisState build() => const ResumeAnalysisState();

  // MOBILE path: receives dart:io File with a real path.
  Future<void> analyseResume(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final pdfService = ref.read(pdfServiceProvider);

    final validationError = pdfService.validateFile(file, ext);
    if (validationError != null) {
      state = ResumeAnalysisState(
        phase: AnalysisPhase.error,
        errorMessage: validationError,
      );
      return;
    }

    final bytes = await file.readAsBytes();
    final fileName = file.path.split(Platform.pathSeparator).last;

    await _runPipeline(
      bytes: bytes,
      ext: ext,
      fileName: fileName,
      ioFile: file, // passed for Supabase upload on mobile
    );
  }

  // WEB path: receives PlatformFile with bytes, no path available.
  Future<void> analyseResumeFromPlatformFile(PlatformFile platformFile) async {
    final ext = platformFile.extension?.toLowerCase() ?? '';
    final bytes = platformFile.bytes;

    if (bytes == null) {
      state = const ResumeAnalysisState(
        phase: AnalysisPhase.error,
        errorMessage: 'Could not read file bytes. Please try again.',
      );
      return;
    }

    // Validate size manually (no File object on web)
    if (platformFile.size > 5 * 1024 * 1024) {
      state = const ResumeAnalysisState(
        phase: AnalysisPhase.error,
        errorMessage: 'File exceeds 5 MB limit.',
      );
      return;
    }

    if (!['pdf', 'docx', 'txt'].contains(ext)) {
      state = const ResumeAnalysisState(
        phase: AnalysisPhase.error,
        errorMessage: 'Unsupported file type.',
      );
      return;
    }

    await _runPipeline(
      bytes: bytes,
      ext: ext,
      fileName: platformFile.name,
      ioFile: null, // no File on web
    );
  }

  // Shared core pipeline. Both mobile and web converge here.
  // ioFile is null on web - Supabase upload uses bytes instead.
  Future<void> _runPipeline({
    required Uint8List bytes,
    required String ext,
    required String fileName,
    required File? ioFile,
  }) async {
    final pdfService = ref.read(pdfServiceProvider);
    final aiService = ref.read(aiServiceProvider);
    final supabaseService = ref.read(supabaseServiceProvider);

    try {
      // Step 1: Parse text from bytes.
      state = const ResumeAnalysisState(phase: AnalysisPhase.parsing);
      final resumeText = await pdfService.extractTextFromBytes(bytes, ext);

      // Step 2: Upload to Supabase if logged in.
      if (!supabaseService.isGuest) {
        state = const ResumeAnalysisState(phase: AnalysisPhase.uploading);
        if (kIsWeb) {
          // Web: upload bytes directly
          await supabaseService.uploadResumeBytes(bytes, fileName, ext);
        } else {
          // Mobile: upload via File
          await supabaseService.uploadResume(ioFile!, ext);
        }
      }

      // Step 3: AI analysis.
      state = const ResumeAnalysisState(phase: AnalysisPhase.analysing);
      final analysisData = await aiService.analyzeResume(resumeText);

      final suggestions = (analysisData['suggestions'] as List?)
              ?.map((s) => {
                    'text': s['text'] ?? '',
                    'category':
                        s['type']?.toString().split('.').last.toLowerCase() ??
                            'improve',
                  })
              .toList() ??
          [];

      // Step 4: Save to Supabase if logged in.
      if (!supabaseService.isGuest) {
        final fileUrl = kIsWeb
            ? await supabaseService.uploadResumeBytes(bytes, fileName, ext)
            : await supabaseService.uploadResume(ioFile!, ext);

        await supabaseService.saveAnalysis(
          fileName: fileName,
          fileUrl: fileUrl,
          rawText: resumeText,
          overallScore: (analysisData['overall_score'] as int?) ?? 0,
          atsScore: (analysisData['ats_score'] as int?) ?? 0,
          missingSections: List<String>.from(
              analysisData['missing_sections'] as List? ?? []),
          weakLanguage:
              List<String>.from(analysisData['weak_language'] as List? ?? []),
          missingKeywords: List<String>.from(
              analysisData['missing_keywords'] as List? ?? []),
          suggestions: suggestions,
        );
      }

      final result = AnalysisResult(
        id: null,
        userId: supabaseService.currentUser?.id ?? '',
        resumeFileName: fileName,
        overallScore: (analysisData['overall_score'] as int?) ?? 0,
        atsScore: (analysisData['ats_score'] as int?) ?? 0,
        missingSections:
            List<String>.from(analysisData['missing_sections'] as List? ?? []),
        weakLanguage:
            List<String>.from(analysisData['weak_language'] as List? ?? []),
        missingKeywords:
            List<String>.from(analysisData['missing_keywords'] as List? ?? []),
        suggestions: (analysisData['suggestions'] as List?)
                ?.map((s) => SuggestionItem(
                      text: s['text'] ?? '',
                      category: SuggestionCategory.fromString(
                          (s['type'] ?? 'improve').toString().toLowerCase()),
                    ))
                .toList() ??
            [],
      );

      state = ResumeAnalysisState(phase: AnalysisPhase.done, result: result);
    } catch (e) {
      state = ResumeAnalysisState(
        phase: AnalysisPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const ResumeAnalysisState();
}

final resumeAnalysisProvider =
    NotifierProvider<ResumeAnalysisNotifier, ResumeAnalysisState>(
        ResumeAnalysisNotifier.new);
