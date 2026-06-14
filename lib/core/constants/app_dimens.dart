// Layout and sizing constants from the CV2Career design system.
// Keep all numeric magic values here.
class AppDimens {
  AppDimens._();

  // Horizontal padding applied to all screens
  static const double paddingH = 16.0;

  // Vertical padding
  static const double paddingV = 16.0;
  static const double paddingVSm = 8.0;
  static const double paddingVLg = 24.0;
  static const double paddingVXl = 32.0;

  // Border radii
  static const double radiusCard = 12.0;
  static const double radiusButton = 8.0;
  static const double radiusPill = 24.0;
  static const double radiusInput = 8.0;
  static const double radiusSm = 4.0;

  // Card
  static const double cardElevation = 0.0; // We use custom shadow, not elevation
  static const double cardBorderWidth = 1.0;

  // Bottom nav height
  static const double bottomNavHeight = 64.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Spacing scale
  static const double sp2 = 2.0;
  static const double sp4 = 4.0;
  static const double sp6 = 6.0;
  static const double sp8 = 8.0;
  static const double sp12 = 12.0;
  static const double sp16 = 16.0;
  static const double sp20 = 20.0;
  static const double sp24 = 24.0;
  static const double sp32 = 32.0;
  static const double sp40 = 40.0;
  static const double sp48 = 48.0;
  static const double sp64 = 64.0;

  // Button heights
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightSm = 36.0;

  // Input field height
  static const double inputHeight = 52.0;

  // Score circle sizes
  static const double scoreCircleLg = 140.0;
  static const double scoreCircleMd = 90.0;
  static const double scoreCircleSm = 60.0;

  // File size limit in bytes (5 MB)
  static const int fileSizeLimitBytes = 5 * 1024 * 1024;

  // AI timeout in seconds
  static const int aiTimeoutSeconds = 30;

  // API retry count and initial backoff
  static const int apiRetryCount = 3;
  static const int apiRetryBackoffMs = 1000;

  // Onboarding
  static const double onboardingImageHeight = 260.0;
}
