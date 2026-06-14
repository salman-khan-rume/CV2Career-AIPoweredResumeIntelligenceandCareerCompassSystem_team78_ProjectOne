import 'package:uuid/uuid.dart';

// Represents a single suggestion item (Add, Remove, or Improve).
class SuggestionItem {
  final String text;
  final SuggestionCategory category;

  const SuggestionItem({
    required this.text,
    required this.category,
  });

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    return SuggestionItem(
      text: json['text'] as String,
      category: SuggestionCategory.fromString(json['category'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'category': category.value,
      };
}

// Three suggestion categories per SRS FR-3.3.
enum SuggestionCategory {
  add('add'),
  remove('remove'),
  improve('improve');

  final String value;
  const SuggestionCategory(this.value);

  static SuggestionCategory fromString(String v) {
    return SuggestionCategory.values.firstWhere(
      (e) => e.value == v,
      orElse: () => SuggestionCategory.improve,
    );
  }
}

// The full resume analysis result per FR-3.1 through FR-3.3.
// TBD-4: This model maps to the Supabase `analysis_results` table (defined in Supabase phase).
class AnalysisResult {
  final String id;
  final String userId;          // empty string for guest sessions
  final String resumeFileName;
  final int overallScore;        // 0-100
  final int atsScore;            // 0-100
  final List<String> missingSections;
  final List<String> weakLanguage;
  final List<String> missingKeywords;
  final List<SuggestionItem> suggestions;
  final DateTime createdAt;

  AnalysisResult({
    String? id,
    required this.userId,
    required this.resumeFileName,
    required this.overallScore,
    required this.atsScore,
    required this.missingSections,
    required this.weakLanguage,
    required this.missingKeywords,
    required this.suggestions,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convenience getters for suggestion categories
  List<SuggestionItem> get addSuggestions =>
      suggestions.where((s) => s.category == SuggestionCategory.add).toList();

  List<SuggestionItem> get removeSuggestions =>
      suggestions.where((s) => s.category == SuggestionCategory.remove).toList();

  List<SuggestionItem> get improveSuggestions =>
      suggestions.where((s) => s.category == SuggestionCategory.improve).toList();

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      resumeFileName: json['resume_file_name'] as String,
      overallScore: (json['overall_score'] as num).toInt(),
      atsScore: (json['ats_score'] as num).toInt(),
      missingSections: List<String>.from(json['missing_sections'] as List),
      weakLanguage: List<String>.from(json['weak_language'] as List),
      missingKeywords: List<String>.from(json['missing_keywords'] as List),
      suggestions: (json['suggestions'] as List)
          .map((s) => SuggestionItem.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'resume_file_name': resumeFileName,
        'overall_score': overallScore,
        'ats_score': atsScore,
        'missing_sections': missingSections,
        'weak_language': weakLanguage,
        'missing_keywords': missingKeywords,
        'suggestions': suggestions.map((s) => s.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  // Creates a copy with updated fields.
  AnalysisResult copyWith({
    String? userId,
    String? resumeFileName,
    int? overallScore,
    int? atsScore,
    List<String>? missingSections,
    List<String>? weakLanguage,
    List<String>? missingKeywords,
    List<SuggestionItem>? suggestions,
  }) {
    return AnalysisResult(
      id: id,
      userId: userId ?? this.userId,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      overallScore: overallScore ?? this.overallScore,
      atsScore: atsScore ?? this.atsScore,
      missingSections: missingSections ?? this.missingSections,
      weakLanguage: weakLanguage ?? this.weakLanguage,
      missingKeywords: missingKeywords ?? this.missingKeywords,
      suggestions: suggestions ?? this.suggestions,
      createdAt: createdAt,
    );
  }
}
