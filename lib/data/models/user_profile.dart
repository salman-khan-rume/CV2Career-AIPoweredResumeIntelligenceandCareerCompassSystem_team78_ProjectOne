// Represents an authenticated user's profile.
// Populated from Supabase Auth + optional profiles table.
class UserProfile {
  final String id;           // Supabase auth user UUID
  final String email;
  final String? fullName;
  final DateTime createdAt;
  final int totalAnalyses;   // Computed from analysis_results table

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    required this.createdAt,
    this.totalAnalyses = 0,
  });

  String get displayName => fullName?.isNotEmpty == true ? fullName! : email.split('@').first;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalAnalyses: (json['total_analyses'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'created_at': createdAt.toIso8601String(),
        'total_analyses': totalAnalyses,
      };
}
