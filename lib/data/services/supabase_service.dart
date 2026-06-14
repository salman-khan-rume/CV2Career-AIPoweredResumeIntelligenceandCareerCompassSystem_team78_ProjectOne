import 'dart:io';
import 'dart:typed_data'; // add this line
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

  /// Sign out current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Stream of auth state changes. Listen in root provider.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── PROFILE ─────────────────────────────────────────────────────────────

  /// Fetch the logged-in user's profile row.
  Future<Map<String, dynamic>?> getProfile() async {
    if (isGuest) return null;
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();
    return response;
  }

  /// Update display name or avatar URL in the profile table.
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    if (isGuest) return;
    await _client.from('profiles').update({
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', currentUser!.id);
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
        .select('id, file_name, overall_score, ats_score, created_at')
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
}
