import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../core/constants/app_constants.dart';

/// Handles resume file validation and text extraction.
/// Supports PDF, DOCX (text only), TXT formats.
/// Works on both mobile (File path) and web (bytes).
class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  // ── VALIDATION ───────────────────────────────────────────────────────────

  /// Returns null if valid, or an error message string if invalid.
  /// Mobile only - uses dart:io File. Web validates in the provider.
  String? validateFile(File file, String extension) {
    final sizeBytes = file.lengthSync();
    if (sizeBytes > AppConstants.maxFileSizeBytes) {
      return 'File exceeds 5 MB limit (${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB).';
    }
    if (!AppConstants.allowedExtensions.contains(extension.toLowerCase())) {
      return 'Unsupported format. Use PDF, DOCX, or TXT.';
    }
    return null;
  }

  // ── TEXT EXTRACTION ──────────────────────────────────────────────────────

  /// Mobile entry point: reads File then delegates to bytes extractor.
  Future<String> extractText(File file, String extension) async {
    final bytes = await file.readAsBytes();
    return extractTextFromBytes(bytes, extension);
  }

  /// Web + shared entry point: extracts text directly from raw bytes.
  /// Called by mobile via extractText, and by web path directly.
  Future<String> extractTextFromBytes(Uint8List bytes, String extension) async {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return _extractFromPdfBytes(bytes);
      case 'txt':
        return utf8.decode(bytes); // utf8 safer than fromCharCodes
      case 'docx':
        return _extractFromDocxBytes(bytes);
      case 'doc':
        return _extractFromDocBytes(); // old binary format - not parseable on web
      default:
        throw Exception('Unsupported file type: $extension');
    }
  }

  // ── PRIVATE EXTRACTORS ───────────────────────────────────────────────────

  /// Extracts text from PDF bytes using Syncfusion.
  Future<String> _extractFromPdfBytes(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();

    if (text.trim().isEmpty) {
      throw Exception(
        'Could not extract text from this PDF. '
        'It may be image-based (scanned). Please use a text-based PDF.',
      );
    }
    return text;
  }

  /// Extracts text from DOCX bytes by properly unpacking the ZIP archive.
  /// Previous version used fromCharCodes which corrupted binary ZIP data.
  Future<String> _extractFromDocxBytes(Uint8List bytes) async {
    try {
      // DOCX is a ZIP archive - decode bytes properly
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find word/document.xml inside the ZIP entries
      final docFile = archive.files.firstWhere(
        (f) => f.name == 'word/document.xml',
        orElse: () => throw Exception('Not a valid DOCX file.'),
      );

      // Decode XML content as UTF-8
      final xmlString = utf8.decode(docFile.content as List<int>);

      // Extract all <w:t> text run contents
      final textMatches = RegExp(r'<w:t[^>]*>([^<]*)<\/w:t>')
          .allMatches(xmlString)
          .map((m) => m.group(1) ?? '')
          .where((s) => s.trim().isNotEmpty)
          .join(' ');

      if (textMatches.trim().isEmpty) {
        throw Exception('No readable text found in DOCX file.');
      }

      return textMatches;
    } catch (e) {
      throw Exception('Failed to read DOCX file: $e');
    }
  }

  /// Old binary .doc format cannot be parsed on web without native libs.
  /// Instructs user to convert to .docx or .pdf instead.
  Future<String> _extractFromDocBytes() async {
    throw Exception(
      'Old .doc format is not supported. '
      'Please resave your file as .docx or .pdf and try again.',
    );
  }
}
