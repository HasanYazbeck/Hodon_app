import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/user_role.dart';
import '../../../domain/models/user.dart';
import '../interfaces/i_auth_repository.dart';

class RemoteAuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  RemoteAuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role.name,
        },
      );

      final payload = _payload(response);
      final user = _userFromPayload(payload) ??
          AppUser(
            id: _readString(payload, const ['userId', 'id']) ?? 'pending_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            fullName: fullName,
            role: role,
            isEmailVerified: false,
            isProfileComplete: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      final accessToken = _readString(payload, const ['accessToken', 'token']) ?? '';
      final refreshToken = _readString(payload, const ['refreshToken']) ?? '';

      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        await _storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
      await _storage.saveUserId(user.id);
      await _storage.saveUserRole(user.role.name);

      return AuthResult(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } on ApiException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      // Support backends that return tokens/user directly after OTP verification.
      final payload = _payload(response);
      final accessToken = _readString(payload, const ['accessToken', 'token']);
      final refreshToken = _readString(payload, const ['refreshToken']);
      final user = _userFromPayload(payload);

      if (accessToken != null && accessToken.isNotEmpty && refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
      if (user != null) {
        await _storage.saveUserId(user.id);
        await _storage.saveUserRole(user.role.name);
      }
    } on ApiException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await _apiClient.post<dynamic>(
        ApiEndpoints.resendOtp,
        data: {'email': email},
      );
    } on ApiException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final payload = _payload(response);
      final accessToken = _readString(payload, const ['accessToken', 'token']);
      final refreshToken = _readString(payload, const ['refreshToken']);

      if (accessToken == null || accessToken.isEmpty || refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Invalid login response from server.');
      }

      await _storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

      final user = _userFromPayload(payload) ?? await _fetchCurrentUserOrThrow();
      await _storage.saveUserId(user.id);
      await _storage.saveUserRole(user.role.name);

      return AuthResult(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } on ApiException catch (e) {
      final normalized = _normalizeLoginError(e);
      throw Exception(normalized);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post<dynamic>(ApiEndpoints.logout);
    } on ApiException {
      // Even if the backend call fails, clear local auth state.
    } finally {
      await _storage.clearAll();
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiClient.post<dynamic>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on ApiException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    try {
      await _apiClient.post<dynamic>(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } on ApiException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final isLoggedIn = await _storage.isLoggedIn();
    if (!isLoggedIn) return null;

    try {
      final data = await _apiClient.get<dynamic>(ApiEndpoints.me);
      final payload = _payload(data);
      final user = _userFromPayload(payload) ?? AppUser.fromJson(payload);
      await _storage.saveUserId(user.id);
      await _storage.saveUserRole(user.role.name);
      return user;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _storage.clearAll();
      }
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  @override
  Future<void> setUserRole(UserRole role) async {
    try {
      await _apiClient.put<dynamic>(
        ApiEndpoints.updateProfile,
        data: {'role': role.name},
      );
      await _storage.saveUserRole(role.name);
    } on ApiException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  @override
  Future<AppUser> updateCurrentUserProfile({
    String? avatarUrl,
    String? bio,
    DateTime? dateOfBirth,
    Gender? gender,
    UserAddress? address,
    bool markProfileComplete = false,
  }) async {
    try {
      final response = await _apiClient.put<dynamic>(
        ApiEndpoints.updateProfile,
        data: {
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
          if (bio != null) 'bio': bio,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
          if (gender != null) 'gender': gender.name,
          if (address != null) 'address': address.toJson(),
          if (markProfileComplete) 'isProfileComplete': true,
        },
      );

      final payload = _payload(response);
      final user = _userFromPayload(payload) ?? AppUser.fromJson(payload);
      await _storage.saveUserId(user.id);
      await _storage.saveUserRole(user.role.name);
      return user;
    } on ApiException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<AppUser> _fetchCurrentUserOrThrow() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('Unable to fetch user profile after login.');
    }
    return user;
  }

  AppUser? _userFromPayload(Map<String, dynamic> payload) {
    final userRaw = payload['user'];
    if (userRaw is Map<String, dynamic>) {
      return AppUser.fromJson(userRaw);
    }
    if (userRaw is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(userRaw));
    }
    return null;
  }

  Map<String, dynamic> _payload(dynamic raw) {
    final root = _toMap(raw);
    final data = root['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return root;
  }

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    throw Exception('Invalid response format.');
  }

  String? _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  String _errorMessage(ApiException exception) {
    if (exception.errorCode != null && exception.errorCode!.isNotEmpty) {
      if (exception.errorCode == 'UNVERIFIED_EMAIL') return 'UNVERIFIED_EMAIL';
    }
    if (exception.message.toUpperCase().contains('UNVERIFIED_EMAIL')) {
      return 'UNVERIFIED_EMAIL';
    }
    return exception.message;
  }

  String _normalizeLoginError(ApiException exception) {
    final message = _errorMessage(exception);
    if (message == 'UNVERIFIED_EMAIL') return message;
    if (exception.statusCode == 401) return 'Invalid email or password.';
    return message;
  }
}

