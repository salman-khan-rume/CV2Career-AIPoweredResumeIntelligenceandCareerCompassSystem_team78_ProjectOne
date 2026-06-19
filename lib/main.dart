import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

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
