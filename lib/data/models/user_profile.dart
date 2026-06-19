// Represents an authenticated user's profile.
// Merged from Supabase Auth (email, id, createdAt) + profiles table (displayName, avatar).
class UserProfile {
  final String id; // Supabase auth user UUID
  final String email; // From auth, always present
  final String? displayName; // From profiles.display_name, nullable
  final DateTime createdAt;
  final int totalAnalyses; // Computed from analysis_results table

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.totalAnalyses = 0,
  });

  // Returns displayName if set, otherwise first part of email.
  String get nameForGreeting =>
      (displayName?.isNotEmpty == true) ? displayName! : email.split('@').first;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      totalAnalyses: (json['total_analyses'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'created_at': createdAt.toIso8601String(),
        'total_analyses': totalAnalyses,
      };
}
