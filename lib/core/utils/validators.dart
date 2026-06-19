import '../constants/app_strings.dart';

// Form field validators.
// Each returns null on success or an error string on failure.
class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.errorFieldRequired;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return AppStrings.errorInvalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errorFieldRequired;
    if (value.length < 8) return AppStrings.errorPasswordTooShort;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.errorFieldRequired;
    if (value != original) return AppStrings.errorPasswordMismatch;
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.errorFieldRequired;
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.errorFieldRequired;
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}
