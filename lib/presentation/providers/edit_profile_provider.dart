import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Handles profile update operations.
/// Invalidates userProfileProvider on success to refresh UI.
class EditProfileNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Updates user's full name in Supabase.
  /// Automatically refreshes userProfileProvider on success.
  Future<void> updateFullName(String fullName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseServiceProvider).updateProfile(
            displayName: fullName,
          );
      // Refresh profile data after successful update
      ref.invalidate(userProfileProvider);
    });
  }

  /// Clear error state after user dismisses error snackbar.
  void clearError() => state = const AsyncValue.data(null);
}

/// Riverpod 3.x: NotifierProvider for profile edits.
final editProfileProvider =
    NotifierProvider<EditProfileNotifier, AsyncValue<void>>(
  EditProfileNotifier.new,
);
