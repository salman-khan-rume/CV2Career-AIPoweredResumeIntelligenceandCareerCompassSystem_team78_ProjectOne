import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../providers/app_routes.dart';
import '../providers/resume_analysis_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_error_widgets.dart';

// Screen 9: Resume Upload.
// User picks a file, sees validation feedback, then triggers analysis.
// Supports both mobile (File path) and web (bytes in memory).
class ResumeUploadScreen extends ConsumerStatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  ConsumerState<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends ConsumerState<ResumeUploadScreen> {
  // Mobile: File object from path. Web: always null.
  File? _selectedFile;

  // Web: raw bytes loaded by file_picker. Mobile: null (uses _selectedFile).
  PlatformFile? _platformFile;

  String? _fileName;
  int? _fileSize;

  // Opens system file picker. On web, bytes are loaded into memory.
  // On mobile, path is used to construct a File object.
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      allowMultiple: false,
      withData: true, // REQUIRED: loads bytes for web; harmless on mobile
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;

    setState(() {
      _platformFile = picked;
      _fileName = picked.name;
      _fileSize = picked.size;

      // Mobile only: build File from path
      if (!kIsWeb && picked.path != null) {
        _selectedFile = File(picked.path!);
      } else {
        _selectedFile = null; // Web has no path
      }
    });

    ref.read(resumeAnalysisProvider.notifier).reset();
  }

  // Passes the right input to the analysis pipeline.
  // Mobile gets File, web gets PlatformFile (bytes inside).
  Future<void> _analyse() async {
    if (kIsWeb) {
      // Web path: pass PlatformFile with bytes
      if (_platformFile == null) return;
      await ref
          .read(resumeAnalysisProvider.notifier)
          .analyseResumeFromPlatformFile(_platformFile!);
    } else {
      // Mobile path: pass File
      if (_selectedFile == null) return;
      await ref
          .read(resumeAnalysisProvider.notifier)
          .analyseResume(_selectedFile!);
    }
  }

  // Returns true when a valid file is ready regardless of platform.
  bool get _hasFile =>
      kIsWeb ? (_platformFile != null) : (_selectedFile != null);

  // Maps AnalysisPhase to display string.
  String _phaseLabel(AnalysisPhase phase) {
    switch (phase) {
      case AnalysisPhase.uploading:
        return AppStrings.uploading;
      case AnalysisPhase.parsing:
        return AppStrings.parsing;
      case AnalysisPhase.analysing:
        return AppStrings.analysing;
      default:
        return AppStrings.loading;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(resumeAnalysisProvider, (_, next) {
      if (next.phase == AnalysisPhase.done && next.result != null) {
        ref.invalidate(userProfileProvider);
        context.push(AppRoutes.analysisResult, extra: next.result!);
      }
    });

    final analysisState = ref.watch(resumeAnalysisProvider);
    final isProcessing = [
      AnalysisPhase.uploading,
      AnalysisPhase.parsing,
      AnalysisPhase.analysing,
    ].contains(analysisState.phase);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.uploadTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimens.sp8),
                  Text(
                    AppStrings.uploadSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sp24),
                  _DropZone(
                    hasFile: _hasFile,
                    fileName: _fileName,
                    fileSize: _fileSize,
                    onTap: isProcessing ? null : _pickFile,
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppDimens.sp24),
                  if (analysisState.phase == AnalysisPhase.error &&
                      analysisState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.sp16),
                      child: ErrorStateWidget(
                        message: analysisState.errorMessage!,
                        onRetry: _hasFile ? _analyse : null,
                      ),
                    ),
                  _TipsCard().animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppDimens.sp32),
                  ElevatedButton(
                    onPressed: (_hasFile && !isProcessing) ? _analyse : null,
                    child: const Text(AppStrings.uploadButton),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
          if (isProcessing)
            LoadingOverlay(message: _phaseLabel(analysisState.phase)),
        ],
      ),
    );
  }
}

// Tappable drop zone - unchanged visually, same as your original.
class _DropZone extends StatelessWidget {
  final bool hasFile;
  final String? fileName;
  final int? fileSize;
  final VoidCallback? onTap;

  const _DropZone({
    required this.hasFile,
    this.fileName,
    this.fileSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: hasFile ? AppColors.primarySurface : AppColors.card,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: hasFile ? AppColors.primary : AppColors.border,
            width: hasFile ? 2 : 1,
          ),
        ),
        child: hasFile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_rounded,
                      size: 48, color: AppColors.primary),
                  const SizedBox(height: AppDimens.sp12),
                  Text(
                    fileName ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileSize != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      AppUtils.formatFileSize(fileSize!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppDimens.sp8),
                  Text(
                    'Tap to change file',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file_rounded,
                      size: 48, color: AppColors.textDisabled),
                  const SizedBox(height: AppDimens.sp12),
                  Text(
                    AppStrings.uploadDropArea,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

// Tips card - unchanged from your original.
class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const tips = [
      'Use standard headings (Experience, Education, Skills)',
      'Avoid tables, graphics, and multiple columns for better ATS parsing',
      'Include measurable achievements with numbers and percentages',
      'Save as PDF for best compatibility',
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: AppDimens.sp8),
              Text('Tips for best results',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppDimens.sp12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.sp8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: AppDimens.sp8),
                    Expanded(
                      child: Text(tip,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
