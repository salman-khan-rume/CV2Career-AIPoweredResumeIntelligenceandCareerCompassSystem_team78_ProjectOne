import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Load .env variables dynamically as a fallback
  if (AppConstants.groqApiKey.isEmpty) {
    try {
      final envContent = await rootBundle.loadString('.env');
      final lines = envContent.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final idx = trimmed.indexOf('=');
        if (idx != -1) {
          final key = trimmed.substring(0, idx).trim();
          final val = trimmed.substring(idx + 1).trim();
          if (key == 'GROQ_API_KEY' && val.isNotEmpty) {
            AppConstants.groqApiKey = val;
          }
        }
      }
    } catch (_) {
      // Fail silently if .env asset is missing or unreadable
    }
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ycwvyecnafikzeuybluu.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_VX5ddQOVyCmhAop2yg1q3g_yv6_V6XT',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    // Update dynamic colors switch before child widgets build
    AppColors.isDark = themeMode == AppThemeMode.dark;

    return MaterialApp.router(
      key: ValueKey(themeMode),
      title: 'CV2Career',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          themeMode == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark,
      routerConfig: router,
    );
  }
}
