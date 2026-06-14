import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase once at startup.
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    // ProviderScope wraps entire app for Riverpod.
    const ProviderScope(child: CV2CareerApp()),
  );
}

class CV2CareerApp extends ConsumerWidget {
  const CV2CareerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch router - rebuilds on auth state change.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CV2Career',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
