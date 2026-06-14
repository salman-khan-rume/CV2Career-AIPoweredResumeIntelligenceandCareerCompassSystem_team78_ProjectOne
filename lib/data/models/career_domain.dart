// Represents one career domain recommendation from the Career Compass engine.
// Per SRS FR-4.2: includes match %, required skills, certifications, and AI reasoning.
class CareerDomain {
  final String key;               // e.g. "software_engineering"
  final String label;             // e.g. "Software Engineering"
  final int matchPercent;         // 0-100
  final int acceptanceProbability; // 0-100, per FR-5.1
  final String aiReasoning;       // AI-generated explanation
  final List<String> requiredSkills;
  final List<String> certifications;

  const CareerDomain({
    required this.key,
    required this.label,
    required this.matchPercent,
    required this.acceptanceProbability,
    required this.aiReasoning,
    required this.requiredSkills,
    required this.certifications,
  });

  factory CareerDomain.fromJson(Map<String, dynamic> json) {
    return CareerDomain(
      key: json['key'] as String,
      label: json['label'] as String,
      matchPercent: (json['match_percent'] as num).toInt(),
      acceptanceProbability: (json['acceptance_probability'] as num).toInt(),
      aiReasoning: json['ai_reasoning'] as String,
      requiredSkills: List<String>.from(json['required_skills'] as List),
      certifications: List<String>.from(json['certifications'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'match_percent': matchPercent,
        'acceptance_probability': acceptanceProbability,
        'ai_reasoning': aiReasoning,
        'required_skills': requiredSkills,
        'certifications': certifications,
      };
}

// Represents a questionnaire answer from the user.
class CompassAnswer {
  final String questionId;
  final String question;
  final String answer;

  const CompassAnswer({
    required this.questionId,
    required this.question,
    required this.answer,
  });
}

// The full Career Compass result payload.
class CompassResult {
  final List<CareerDomain> domains;
  final DateTime generatedAt;

  const CompassResult({
    required this.domains,
    required this.generatedAt,
  });
}
