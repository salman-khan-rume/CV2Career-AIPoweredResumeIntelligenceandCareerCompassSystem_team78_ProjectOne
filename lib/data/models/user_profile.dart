// Represents an authenticated user's profile.
// Merged from Supabase Auth (email, id, createdAt) + profiles table (displayName, avatar).
class UserProfile {
  final String id; // Supabase auth user UUID
  final String email; // From auth, always present
  final String? displayName; // From profiles.display_name, nullable
  final String? avatarUrl; // From profiles.avatar_url, nullable
  final DateTime createdAt;
  final int totalAnalyses; // Computed from analysis_results table
  final String? primaryCvUrl;
  final String? primaryCvText;
  final String? primaryCvName;
  final DateTime? primaryCvUpdatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.totalAnalyses = 0,
    this.primaryCvUrl,
    this.primaryCvText,
    this.primaryCvName,
    this.primaryCvUpdatedAt,
  });

  // Returns displayName if set, otherwise first part of email.
  String get nameForGreeting =>
      (displayName?.isNotEmpty == true) ? displayName! : email.split('@').first;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseDateTimeNullable(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: parseDateTime(json['created_at']),
      totalAnalyses: (json['total_analyses'] as num?)?.toInt() ?? 0,
      primaryCvUrl: json['primary_cv_url'] as String?,
      primaryCvText: json['primary_cv_text'] as String?,
      primaryCvName: json['primary_cv_name'] as String?,
      primaryCvUpdatedAt: parseDateTimeNullable(json['primary_cv_updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
        'total_analyses': totalAnalyses,
        'primary_cv_url': primaryCvUrl,
        'primary_cv_text': primaryCvText,
        'primary_cv_name': primaryCvName,
        'primary_cv_updated_at': primaryCvUpdatedAt?.toIso8601String(),
      };
}
