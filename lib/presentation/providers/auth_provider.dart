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
    try {
      await ref.read(supabaseServiceProvider).register(
            email: email,
            password: password,
            displayName: fullName,
          );
      // Create profile row after successful registration
      await ref.read(supabaseServiceProvider).createProfile(
            displayName: fullName,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      final msg = await _mapAuthException(e, email);
      state = AsyncValue.error(msg, st);
    }
  }

  // Signs in with email and password.
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(supabaseServiceProvider).login(
            email: email,
            password: password,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      final msg = await _mapAuthException(e, email);
      state = AsyncValue.error(msg, st);
    }
  }

  // Sends password reset email.
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(supabaseServiceProvider).sendPasswordReset(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      final msg = await _mapAuthException(e, email);
      state = AsyncValue.error(msg, st);
    }
  }

  // Updates user's password.
  Future<void> updatePassword(String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(supabaseServiceProvider).updatePassword(newPassword);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      final msg = await _mapAuthException(e);
      state = AsyncValue.error(msg, st);
    }
  }

  // Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(supabaseServiceProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      final msg = await _mapAuthException(e);
      state = AsyncValue.error(msg, st);
    }
  }

  // Clears error state after user dismisses snackbar.
  void clearError() => state = const AsyncValue.data(null);

  // Maps technical Supabase/Auth exceptions to clean, user-friendly messages.
  Future<String> _mapAuthException(dynamic e, [String? email]) async {
    if (e is AuthException) {
      final code = e.code?.toLowerCase() ?? '';
      final msg = e.message.toLowerCase();

      // Rate limit / too many requests (such as forgot password spamming)
      if (e.statusCode == '429' ||
          code.contains('rate_limit') ||
          msg.contains('rate limit') ||
          msg.contains('too many requests')) {
        if (msg.contains('once every 60 seconds')) {
          return 'For security reasons, you can only request a password reset once every 60 seconds. Please wait and try again.';
        }
        return 'Too many attempts. Please wait a moment and try again.';
      }

      // Invalid credentials
      if (code == 'invalid_credentials' || msg.contains('invalid login credentials')) {
        return 'Incorrect email or password. Please check your credentials, or sign up to create a new account.';
      }

      // User already exists
      if (code == 'user_already_exists' ||
          msg.contains('already registered') ||
          msg.contains('already exists')) {
        return 'An account with this email already exists. Please sign in instead.';
      }

      // Invalid email
      if (msg.contains('invalid email')) {
        return 'Please enter a valid email address.';
      }

      // Weak password
      if (msg.contains('password should be at least')) {
        return 'Password is too weak. It must be at least 6 characters long.';
      }

      return e.message;
    }

    final errString = e.toString();
    if (errString.contains('AuthException') || errString.contains('AuthApiException')) {
      return errString
          .replaceAll(RegExp(r'^AuthException\(message:\s*'), '')
          .replaceAll(RegExp(r'^AuthApiException\(message:\s*'), '')
          .replaceAll(RegExp(r',\s*statusCode:\s*\d+.*$'), '')
          .replaceAll(RegExp(r'\)$'), '');
    }

    return errString;
  }
}

// Riverpod 3.x: use NotifierProvider instead of StateNotifierProvider.
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
