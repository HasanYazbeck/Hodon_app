import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/interfaces/i_auth_repository.dart';
import '../../data/repositories/interfaces/i_sitter_repository.dart';
import '../../data/repositories/interfaces/i_booking_repository.dart';
import '../../data/repositories/interfaces/i_payment_repository.dart';
import '../../data/repositories/mock/mock_auth_repository.dart';
import '../../data/repositories/mock/mock_sitter_repository.dart';
import '../../data/repositories/mock/mock_booking_repository.dart';
import '../../data/repositories/mock/mock_payment_repository.dart';
import '../../data/repositories/remote/remote_auth_repository.dart';

// ── Core services ──────────────────────────────────────────────────────────

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});

// ── Repositories ───────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  const useRemoteAuth = bool.fromEnvironment('USE_REMOTE_AUTH', defaultValue: false);
  if (useRemoteAuth) {
    return RemoteAuthRepository(
      apiClient: ref.watch(apiClientProvider),
      storage: ref.watch(secureStorageProvider),
    );
  }
  return MockAuthRepository(ref.watch(secureStorageProvider));
});

final sitterRepositoryProvider = Provider<ISitterRepository>((ref) {
  return MockSitterRepository();
});

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  return MockBookingRepository();
});

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  return MockPaymentRepository();
});

