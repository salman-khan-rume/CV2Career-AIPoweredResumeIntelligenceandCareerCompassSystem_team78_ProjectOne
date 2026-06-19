import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode enum: light or dark.
enum AppThemeMode { light, dark }

/// Theme notifier - manages light/dark mode state.
class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    // Default: light mode. Can load from SharedPreferences later.
    return AppThemeMode.light;
  }

  /// Toggle between light and dark.
  void toggle() {
    state =
        state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
  }

  /// Set specific mode.
  void setMode(AppThemeMode mode) {
    state = mode;
  }
}

/// Riverpod provider for theme state.
/// Usage: final mode = ref.watch(themeProvider);
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  () => ThemeNotifier(),
);
