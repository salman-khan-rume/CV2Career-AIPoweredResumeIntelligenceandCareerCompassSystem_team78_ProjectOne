// App-wide constants. Never hardcode these values elsewhere.
class AppConstants {
  AppConstants._();

  // Supabase
  static const String supabaseUrl = 'https://ycwvyecnafikzeuybluu.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_VX5ddQOVyCmhAop2yg1q3g_yv6_V6XT';

  // Groq
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  // File limits
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'txt'];

  // AI config
  static const int aiTimeoutSeconds = 30;
  static const int aiMaxRetries = 3;

  // Storage
  static const String resumesBucket = 'resumes';
}
