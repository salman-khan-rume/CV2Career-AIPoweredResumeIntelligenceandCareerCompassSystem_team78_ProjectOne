import 'package:flutter/material.dart';

/// Light mode color palette for CV2Career.
class AppColorsLight {
  AppColorsLight._();

  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF2E5AA8);
  static const Color primarySurface = Color(0xFFEEF2F9);
  static const Color success = Color(0xFF10B981);
  static const Color successSurface = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF9C3);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSurface = Color(0xFFFEE2E2);
  static const Color accent = Color(0xFF0D9488);
  static const Color accentLight = Color(0xFF14B8A6);
  static const Color accentSurface = Color(0xFFCCFBF1);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderFocus = Color(0xFF1E3A8A);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
  static const Color overlay = Color(0x801A1A1A);
  static const Color scoreLow = Color(0xFFDC2626);
  static const Color scoreMid = Color(0xFFF59E0B);
  static const Color scoreHigh = Color(0xFF10B981);
  static const Color navActive = Color(0xFF1E3A8A);
  static const Color navInactive = Color(0xFF94A3B8);
  static const Color navBackground = Color(0xFFFFFFFF);
}

/// Dark mode color palette for CV2Career.
class AppColorsDark {
  AppColorsDark._();

  static const Color background = Color(0xFF020617);
  static const Color card = Color(0xFF0F172A);
  static const Color primary = Color(0xFF60A5FA);
  static const Color primaryLight = Color(0xFF93C5FD);
  static const Color primarySurface = Color(0xFF1E3A5F);
  static const Color success = Color(0xFF34D399);
  static const Color successSurface = Color(0xFF064E3B);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningSurface = Color(0xFF451A03);
  static const Color danger = Color(0xFFF87171);
  static const Color dangerSurface = Color(0xFF7C2D12);
  static const Color accent = Color(0xFF2DD4BF);
  static const Color accentLight = Color(0xFF67E8F9);
  static const Color accentSurface = Color(0xFF134E4A);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF475569);
  static const Color textOnPrimary = Color(0xFF020617);
  static const Color border = Color(0xFF374151);
  static const Color borderFocus = Color(0xFF60A5FA);
  static const Color divider = Color(0xFF1E293B);
  static const Color shimmerBase = Color(0xFF1E293B);
  static const Color shimmerHighlight = Color(0xFF334155);
  static const Color overlay = Color(0xCC020617);
  static const Color scoreLow = Color(0xFFF87171);
  static const Color scoreMid = Color(0xFFFBBF24);
  static const Color scoreHigh = Color(0xFF34D399);
  static const Color navActive = Color(0xFF60A5FA);
  static const Color navInactive = Color(0xFF64748B);
  static const Color navBackground = Color(0xFF0F172A);
}

/// Consolidated color palette for CV2Career.
/// Adapts dynamically to light and dark theme mode.
class AppColors {
  AppColors._();

  /// Global switch representing active theme mode.
  /// Set by the root widget when the theme changes.
  static bool isDark = false;

  // Backgrounds
  static Color get background => isDark ? AppColorsDark.background : AppColorsLight.background;
  static Color get card => isDark ? AppColorsDark.card : AppColorsLight.card;

  // Primary palette
  static Color get primary => isDark ? AppColorsDark.primary : AppColorsLight.primary;
  static Color get primaryLight => isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight;
  static Color get primarySurface => isDark ? AppColorsDark.primarySurface : AppColorsLight.primarySurface;

  // Semantic colors
  static Color get success => isDark ? AppColorsDark.success : AppColorsLight.success;
  static Color get successSurface => isDark ? AppColorsDark.successSurface : AppColorsLight.successSurface;
  static Color get warning => isDark ? AppColorsDark.warning : AppColorsLight.warning;
  static Color get warningSurface => isDark ? AppColorsDark.warningSurface : AppColorsLight.warningSurface;
  static Color get danger => isDark ? AppColorsDark.danger : AppColorsLight.danger;
  static Color get dangerSurface => isDark ? AppColorsDark.dangerSurface : AppColorsLight.dangerSurface;

  // Accent (Teal)
  static Color get accent => isDark ? AppColorsDark.accent : AppColorsLight.accent;
  static Color get accentLight => isDark ? AppColorsDark.accentLight : AppColorsLight.accentLight;
  static Color get accentSurface => isDark ? AppColorsDark.accentSurface : AppColorsLight.accentSurface;

  // Text
  static Color get textPrimary => isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
  static Color get textSecondary => isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
  static Color get textDisabled => isDark ? AppColorsDark.textDisabled : AppColorsLight.textDisabled;
  static Color get textOnPrimary => isDark ? AppColorsDark.textOnPrimary : AppColorsLight.textOnPrimary;

  // Borders
  static Color get border => isDark ? AppColorsDark.border : AppColorsLight.border;
  static Color get borderFocus => isDark ? AppColorsDark.borderFocus : AppColorsLight.borderFocus;

  // Misc
  static Color get divider => isDark ? AppColorsDark.divider : AppColorsLight.divider;
  static Color get shimmerBase => isDark ? AppColorsDark.shimmerBase : AppColorsLight.shimmerBase;
  static Color get shimmerHighlight => isDark ? AppColorsDark.shimmerHighlight : AppColorsLight.shimmerHighlight;
  static Color get overlay => isDark ? AppColorsDark.overlay : AppColorsLight.overlay;

  // Score gradient stops
  static Color get scoreLow => isDark ? AppColorsDark.scoreLow : AppColorsLight.scoreLow;
  static Color get scoreMid => isDark ? AppColorsDark.scoreMid : AppColorsLight.scoreMid;
  static Color get scoreHigh => isDark ? AppColorsDark.scoreHigh : AppColorsLight.scoreHigh;

  // Bottom nav
  static Color get navActive => isDark ? AppColorsDark.navActive : AppColorsLight.navActive;
  static Color get navInactive => isDark ? AppColorsDark.navInactive : AppColorsLight.navInactive;
  static Color get navBackground => isDark ? AppColorsDark.navBackground : AppColorsLight.navBackground;
}
