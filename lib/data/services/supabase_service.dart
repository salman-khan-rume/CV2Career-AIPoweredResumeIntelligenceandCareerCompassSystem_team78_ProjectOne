import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

/// Handles all Supabase interactions: auth, storage, and database reads/writes.
/// Guest users never call write methods here; that is enforced at the screen level.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  // Convenience getter for the Supabase client
  SupabaseClient get _client => Supabase.instance.client;

  // Current logged-in user (null if guest)
  User? get currentUser => _client.auth.currentUser;
  bool get isGuest => currentUser == null;

  // ── AUTH ────────────────────────────────────────────────────────────────

  /// Register with email and password.
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
  }

  /// Login with email and password.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Send password reset email.
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update user's password.
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Sign out current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Stream of auth state changes. Listen in root provider.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── PROFILE ─────────────────────────────────────────────────────────────

  /// Create a new profile row for a user (call after registration).
  /// Sets up initial email and display name in profiles table.
  Future<void> createProfile({
    required String displayName,
  }) async {
    if (isGuest) return;
    if (currentUser == null) throw Exception('No authenticated user');

    try {
      await _client.from('profiles').insert({
        'id': currentUser!.id,
        'email': currentUser!.email,
        'display_name': displayName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Fetch the logged-in user's profile row.
  /// Merges auth email + profile table data to avoid null fields.
  /// Returns null if no user logged in.
  /// Throws exception if fetch fails.
  Future<Map<String, dynamic>?> getProfile() async {
    if (isGuest) return null;
    if (currentUser == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      // Count analyses dynamically from resume_analyses table
      final countRes = await _client
          .from('resume_analyses')
          .select('id')
          .eq('user_id', currentUser!.id);
      final totalAnalyses = countRes.length;

      // Merge auth email + profile data so model always has required fields.
      if (response != null) {
        return {
          ...response,
          'email': currentUser!.email,
          'id': currentUser!.id,
          'total_analyses': totalAnalyses,
        };
      }

      // Profile row doesn't exist yet; return minimal auth-based profile.
      return {
        'id': currentUser!.id,
        'email': currentUser!.email,
        'display_name': null,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'total_analyses': totalAnalyses,
      };
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Update display name or avatar URL in the profile table.
  /// Creates profile if it doesn't exist.
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    if (isGuest) return;
    if (currentUser == null) throw Exception('No authenticated user');

    try {
      // Try update first
      await _client.from('profiles').update({
        if (displayName != null) 'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);
    } catch (e) {
      // If update fails, try to create profile
      try {
        await createProfile(
          displayName: displayName ?? 'User',
        );
        // Retry the update after creation
        await _client.from('profiles').update({
          if (displayName != null) 'display_name': displayName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentUser!.id);
      } catch (_) {
        throw Exception('Failed to update profile: $e');
      }
    }
  }

  // ── STORAGE ─────────────────────────────────────────────────────────────

  /// Upload resume file to Supabase Storage.
  /// Files are stored under {userId}/{uuid}.{ext} so RLS can match folder to user.
  Future<String> uploadResume(File file, String extension) async {
    if (isGuest) throw Exception('Guest users cannot upload files.');

    final fileName = '${const Uuid().v4()}.$extension';
    final path = '${currentUser!.id}/$fileName';

    await _client.storage.from(AppConstants.resumesBucket).upload(path, file);

    // Return the public URL (private bucket, so this is a signed path)
    return path;
  }

  /// Upload resume from raw bytes (web path - no dart:io File available).
  /// Mirrors uploadResume but accepts Uint8List instead of File.
  Future<String> uploadResumeBytes(
    Uint8List bytes,
    String originalFileName,
    String extension,
  ) async {
    if (isGuest) throw Exception('Guest users cannot upload files.');

    final fileName = '${const Uuid().v4()}.$extension';
    final path = '${currentUser!.id}/$fileName';

    await _client.storage
        .from(AppConstants.resumesBucket)
        .uploadBinary(path, bytes);

    return path;
  }

  /// Get a short-lived signed URL for a stored resume (valid 1 hour).
  Future<String> getResumeSignedUrl(String storagePath) async {
    final response = await _client.storage
        .from(AppConstants.resumesBucket)
        .createSignedUrl(storagePath, 3600);
    return response;
  }

  /// Upload avatar image from bytes and return its public URL.
  Future<String> uploadAvatarBytes(Uint8List bytes, String extension) async {
    if (isGuest) throw Exception('Guest users cannot upload files.');

    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '${currentUser!.id}/$fileName';

    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$extension',
            upsert: true,
          ),
        );

    return _client.storage.from('avatars').getPublicUrl(path);
  }

  // ── RESUME ANALYSES ─────────────────────────────────────────────────────

  /// Save a completed resume analysis result to the database.
  Future<String> saveAnalysis({
    required String fileName,
    String? fileUrl,
    String? rawText,
    required int overallScore,
    required int atsScore,
    required List<String> missingSections,
    required List<String> weakLanguage,
    required List<String> missingKeywords,
    required List<Map<String, dynamic>> suggestions,
  }) async {
    if (isGuest) throw Exception('Guest users cannot save analyses.');

    final response = await _client
        .from('resume_analyses')
        .insert({
          'user_id': currentUser!.id,
          'file_name': fileName,
          'file_url': fileUrl,
          'raw_text': rawText,
          'overall_score': overallScore,
          'ats_score': atsScore,
          'missing_sections': missingSections,
          'weak_language': weakLanguage,
          'missing_keywords': missingKeywords,
          'suggestions': suggestions,
          'ai_provider': 'gemini',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  /// Fetch all analyses for the current user, newest first.
  Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    if (isGuest) return [];
    final response = await _client
        .from('resume_analyses')
        .select('id, user_id, file_name, overall_score, ats_score, created_at, suggestions, missing_sections, weak_language, missing_keywords')
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single analysis by ID (full detail for result screen).
  Future<Map<String, dynamic>?> getAnalysisById(String id) async {
    if (isGuest) return null;
    return await _client
        .from('resume_analyses')
        .select()
        .eq('id', id)
        .eq('user_id', currentUser!.id)
        .maybeSingle();
  }

  // ── CAREER COMPASS ───────────────────────────────────────────────────────

  /// Save career compass questionnaire + recommendations.
  Future<String> saveCareerCompassResult({
    String? analysisId,
    required List<Map<String, dynamic>> questionnaire,
    required List<Map<String, dynamic>> recommendations,
  }) async {
    if (isGuest) throw Exception('Guest users cannot save results.');

    final response = await _client
        .from('career_compass_results')
        .insert({
          'user_id': currentUser!.id,
          'analysis_id': analysisId,
          'questionnaire': questionnaire,
          'recommendations': recommendations,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  // ── SKILL GAP ────────────────────────────────────────────────────────────

  /// Save skill gap analysis result for a chosen career domain.
  Future<void> saveSkillGapResult({
    String? compassResultId,
    required String careerDomain,
    required int acceptanceScore,
    required List<String> skillsPresent,
    required List<String> skillsPartial,
    required List<String> skillsMissing,
    required List<Map<String, dynamic>> roadmap,
  }) async {
    if (isGuest) throw Exception('Guest users cannot save results.');

    await _client.from('skill_gap_results').insert({
      'user_id': currentUser!.id,
      'compass_result_id': compassResultId,
      'career_domain': careerDomain,
      'acceptance_score': acceptanceScore,
      'skills_present': skillsPresent,
      'skills_partial': skillsPartial,
      'skills_missing': skillsMissing,
      'roadmap': roadmap,
    });
  }

  // ── PRIMARY CV ───────────────────────────────────────────────────────────

  /// Save primary CV: Upload file to storage and update profile record.
  Future<void> savePrimaryCV({
    required Uint8List bytes,
    required String fileName,
    required String extension,
    required String extractedText,
  }) async {
    if (isGuest) throw Exception('Guest users cannot save a primary CV.');
    if (currentUser == null) throw Exception('No authenticated user');

    // 1. Upload file to storage
    final storagePath = await uploadResumeBytes(bytes, fileName, extension);

    // 2. Update profiles table
    await _client.from('profiles').update({
      'primary_cv_url': storagePath,
      'primary_cv_text': extractedText,
      'primary_cv_name': fileName,
      'primary_cv_updated_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);
  }

  /// Delete primary CV from storage and clear profile fields.
  Future<void> deletePrimaryCV() async {
    if (isGuest) return;
    if (currentUser == null) throw Exception('No authenticated user');

    try {
      // 1. Get current primary CV path
      final profile = await _client
          .from('profiles')
          .select('primary_cv_url')
          .eq('id', currentUser!.id)
          .maybeSingle();

      final storagePath = profile?['primary_cv_url'] as String?;

      // 2. Clear profile columns
      await _client.from('profiles').update({
        'primary_cv_url': null,
        'primary_cv_text': null,
        'primary_cv_name': null,
        'primary_cv_updated_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);

      // 3. Delete from storage if path exists
      if (storagePath != null && storagePath.isNotEmpty) {
        await _client.storage
            .from(AppConstants.resumesBucket)
            .remove([storagePath]);
      }
    } catch (e) {
      throw Exception('Failed to delete primary CV: $e');
    }
  }
}
