import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Miscellaneous utility functions shared across the app.
class AppUtils {
  AppUtils._();

  // Returns a color based on a 0-100 score value.
  // Low (0-40): danger red, Mid (41-70): warning amber, High (71-100): success green.
  static Color scoreColor(int score) {
    if (score <= 40) return AppColors.scoreLow;
    if (score <= 70) return AppColors.scoreMid;
    return AppColors.scoreHigh;
  }

  // Returns surface color for score (used for chip/badge backgrounds).
  static Color scoreSurface(int score) {
    if (score <= 40) return AppColors.dangerSurface;
    if (score <= 70) return AppColors.warningSurface;
    return AppColors.successSurface;
  }

  // Formats a DateTime to "MMM dd, yyyy" (e.g. "Mar 20, 2026").
  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  // Converts bytes to a human-readable size string.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Truncates a string to maxLength and adds ellipsis.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Capitalises the first letter of each word.
  static String titleCase(String text) {
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  // Returns a greeting based on current hour.
  static String timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
