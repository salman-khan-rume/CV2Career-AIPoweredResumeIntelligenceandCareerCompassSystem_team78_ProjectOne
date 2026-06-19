import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/supabase_service.dart';
import '../../data/models/user_profile.dart';

// Provides the SupabaseService singleton to all providers.
final supabaseServiceProvider =
    Provider<SupabaseService>((ref) => SupabaseService.instance);

// Watches the Supabase auth state stream.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(supabaseServiceProvider).authStateChanges;
});

// Returns true if the current user is authenticated.
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session != null;
});

// Manages guest mode state explicitly
class GuestModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setGuest(bool value) {
    state = value;
  }
}

final guestModeProvider = NotifierProvider<GuestModeNotifier, bool>(
  GuestModeNotifier.new,
);

// Returns true if the user is in guest mode.
final isGuestProvider = Provider<bool>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  if (isLoggedIn) return false;
  return ref.watch(guestModeProvider);
});

// Provides the current user's profile data. Null for guests.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(authStateProvider);
  final data = await ref.read(supabaseServiceProvider).getProfile();
  if (data == null) return null;
  return UserProfile.fromJson(data);
});

// Handles sign-in, register, and sign-out actions.
// Riverpod 3.x: use Notifier<T> instead of StateNotifier<T>.
class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  // Registers a new user.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseServiceProvider).register(
            email: email,
            password: password,
            displayName: fullName,
          );
      // Create profile row after successful registration
      await ref.read(supabaseServiceProvider).createProfile(
            displayName: fullName,
          );
    });
  }

  // Signs in with email and password.
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => ref.read(supabaseServiceProvider).login(
              email: email,
              password: password,
            ));
  }

  // Sends password reset email.
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(supabaseServiceProvider).sendPasswordReset(email));
  }

  // Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(ref.read(supabaseServiceProvider).signOut);
  }

  // Clears error state after user dismisses snackbar.
  void clearError() => state = const AsyncValue.data(null);
}

// Riverpod 3.x: use NotifierProvider instead of StateNotifierProvider.
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
