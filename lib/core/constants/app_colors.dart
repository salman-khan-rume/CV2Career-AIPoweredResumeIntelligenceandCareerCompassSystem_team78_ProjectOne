import 'package:flutter/material.dart';

// Color tokens from the CV2Career design system.
// Never use raw Color() values in widgets - always reference this class.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFFFAFAFA);
  static const Color card = Color(0xFFFFFFFF);

  // Primary palette
  static const Color primary = Color(0xFF1A3557);       // Deep navy
  static const Color primaryLight = Color(0xFF2A4F7A);  // Lighter navy for hover/states
  static const Color primarySurface = Color(0xFFEEF2F7); // Very light navy tint

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF9C3);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSurface = Color(0xFFFEE2E2);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderFocus = Color(0xFF1A3557);

  // Misc
  static const Color divider = Color(0xFFF3F4F6);
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);
  static const Color overlay = Color(0x801A1A1A);

  // Score gradient stops
  static const Color scoreLow = Color(0xFFEF4444);    // 0-40
  static const Color scoreMid = Color(0xFFF59E0B);    // 41-70
  static const Color scoreHigh = Color(0xFF22C55E);   // 71-100

  // Bottom nav
  static const Color navActive = Color(0xFF1A3557);
  static const Color navInactive = Color(0xFF6B7280);
  static const Color navBackground = Color(0xFFFFFFFF);
}
