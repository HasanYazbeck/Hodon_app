import '../../../domain/models/user.dart';
import '../../../domain/enums/user_role.dart';

abstract class IAuthRepository {
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> resendOtp({required String email});

  Future<AuthResult> login({required String email, required String password});

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<AppUser?> getCurrentUser();

  Future<bool> isLoggedIn();

  Future<void> setUserRole(UserRole role);
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

