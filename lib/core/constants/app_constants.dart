class AppConstants {
  AppConstants._();

  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ycwvyecnafikzeuybluu.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_VX5ddQOVyCmhAop2yg1q3g_yv6_V6XT',
  );

  // Groq - Loaded from environment
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  // File limits
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  static const List<String> allowedExtensions = ['pdf', 'docx', 'txt'];

  // AI config
  static const int aiTimeoutSeconds = 30;
  static const int aiMaxRetries = 3;

  // Storage
  static const String resumesBucket = 'resumes';
}
