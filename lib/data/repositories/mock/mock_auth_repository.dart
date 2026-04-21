import '../../../domain/models/user.dart';
import '../../../domain/enums/user_role.dart';
import '../interfaces/i_auth_repository.dart';
import '../../../core/storage/secure_storage_service.dart';

class MockAuthRepository implements IAuthRepository {
  final SecureStorageService _storage;

  // Simulated in-memory user store
  static final Map<String, _MockUser> _users = {
    'parent@test.com': _MockUser(
      id: 'user_parent_1',
      email: 'parent@test.com',
      password: 'Password1',
      fullName: 'Sara Khalil',
      role: UserRole.parent,
      isEmailVerified: true,
      isProfileComplete: true,
    ),
    'sitter@test.com': _MockUser(
      id: 'user_sitter_1',
      email: 'sitter@test.com',
      password: 'Password1',
      fullName: 'Lara Haddad',
      role: UserRole.babysitter,
      isEmailVerified: true,
      isProfileComplete: true,
    ),
  };

  MockAuthRepository(this._storage);

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_users.containsKey(email)) {
      throw Exception('An account with this email already exists.');
    }
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _users[email] = _MockUser(
      id: id,
      email: email,
      password: password,
      fullName: fullName,
      role: UserRole.parent, // set after role selection
      isEmailVerified: false,
      isProfileComplete: false,
    );
    // Don't issue tokens yet — require OTP first
    return AuthResult(
      accessToken: '',
      refreshToken: '',
      user: _buildUser(_users[email]!),
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In mock, any 6-digit code works
    if (otp.length != 6) throw Exception('Invalid OTP');
    final user = _users[email];
    if (user == null) throw Exception('User not found');
    _users[email] = user.copyWith(isEmailVerified: true);
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = _users[email];
    if (user == null || user.password != password) {
      throw Exception('Invalid email or password.');
    }
    if (!user.isEmailVerified) {
      throw Exception('UNVERIFIED_EMAIL');
    }
    const token = 'mock_access_token_xyz';
    const refresh = 'mock_refresh_token_xyz';
    await _storage.saveTokens(accessToken: token, refreshToken: refresh);
    await _storage.saveUserId(user.id);
    await _storage.saveUserRole(user.role.name);
    return AuthResult(
      accessToken: token,
      refreshToken: refresh,
      user: _buildUser(user),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _storage.clearAll();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!_users.containsKey(email)) throw Exception('No account found with this email.');
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Mock: accepts any token
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final userId = await _storage.getUserId();
    if (userId == null) return null;
    final entry = _users.values.where((u) => u.id == userId).firstOrNull;
    return entry != null ? _buildUser(entry) : null;
  }

  @override
  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  @override
  Future<void> setUserRole(UserRole role) async {
    final userId = await _storage.getUserId();
    if (userId == null) return;
    final entry = _users.entries.where((e) => e.value.id == userId).firstOrNull;
    if (entry != null) {
      _users[entry.key] = entry.value.copyWith(role: role);
      await _storage.saveUserRole(role.name);
    }
  }

  AppUser _buildUser(_MockUser u) => AppUser(
        id: u.id,
        email: u.email,
        fullName: u.fullName,
        role: u.role,
        isEmailVerified: u.isEmailVerified,
        isProfileComplete: u.isProfileComplete,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime.now(),
      );
}

class _MockUser {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final UserRole role;
  final bool isEmailVerified;
  final bool isProfileComplete;

  const _MockUser({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    required this.isEmailVerified,
    required this.isProfileComplete,
  });

  _MockUser copyWith({
    UserRole? role,
    bool? isEmailVerified,
    bool? isProfileComplete,
  }) =>
      _MockUser(
        id: id,
        email: email,
        password: password,
        fullName: fullName,
        role: role ?? this.role,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      );
}
