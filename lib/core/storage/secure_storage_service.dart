import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';
  static const _parentBookingTermsPrefix = 'parent_booking_terms_accepted_';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: _keyUserId, value: userId);
  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  Future<void> saveUserRole(String role) =>
      _storage.write(key: _keyUserRole, value: role);
  Future<String?> getUserRole() => _storage.read(key: _keyUserRole);

  Future<bool> hasAcceptedParentBookingTerms(String userId) async {
    final value = await _storage.read(key: '$_parentBookingTermsPrefix$userId');
    return value == 'true';
  }

  Future<void> acceptParentBookingTerms(String userId) {
    return _storage.write(
        key: '$_parentBookingTermsPrefix$userId', value: 'true');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
