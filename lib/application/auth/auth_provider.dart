import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/app_enums.dart';
import '../../domain/models/user.dart';
import '../../domain/enums/user_role.dart';
import '../providers.dart';

// ── Auth State ─────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthOtpRequired extends AuthState {
  final String email;
  const AuthOtpRequired(this.email);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ── Auth Notifier ──────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthInitial());

  final Ref _ref;

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.register(email: email, password: password, fullName: fullName);
      state = AuthOtpRequired(email);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = const AuthLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.verifyOtp(email: email, otp: otp);
      return true;
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final result = await repo.login(email: email, password: password);
      state = AuthAuthenticated(result.user);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg == 'UNVERIFIED_EMAIL') {
        state = AuthOtpRequired(email);
      } else {
        state = AuthError(msg);
      }
    }
  }

  Future<void> logout() async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.logout();
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> setRole(UserRole role) async {
    final repo = _ref.read(authRepositoryProvider);
    await repo.setUserRole(role);
    final user = await repo.getCurrentUser();
    if (user != null) state = AuthAuthenticated(user);
  }

  Future<bool> updateProfile({
    String? avatarUrl,
    String? bio,
    DateTime? dateOfBirth,
    Gender? gender,
    UserAddress? address,
    bool markProfileComplete = false,
  }) async {
    final prev = state;
    if (prev is! AuthAuthenticated) return false;
    try {
      final updated = await _ref.read(authRepositoryProvider).updateCurrentUserProfile(
            avatarUrl: avatarUrl,
            bio: bio,
            dateOfBirth: dateOfBirth,
            gender: gender,
            address: address,
            markProfileComplete: markProfileComplete,
          );
      state = AuthAuthenticated(updated);
      return true;
    } catch (_) {
      state = prev;
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.forgotPassword(email: email);
      state = const AuthUnauthenticated();
      return true;
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Convenience selector — returns the current authenticated user or null
final currentUserProvider = Provider<AppUser?>((ref) {
  final state = ref.watch(authProvider);
  return state is AuthAuthenticated ? state.user : null;
});

