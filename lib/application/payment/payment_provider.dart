import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/saved_payment_method.dart';
import '../providers.dart';

final paymentMethodsProvider =
    StateNotifierProvider<PaymentMethodsNotifier, AsyncValue<List<SavedPaymentMethod>>>((ref) {
  return PaymentMethodsNotifier(ref);
});

final defaultSavedPaymentMethodProvider = Provider<SavedPaymentMethod?>((ref) {
  final methodsAsync = ref.watch(paymentMethodsProvider);
  return methodsAsync.maybeWhen(
    data: (methods) => methods.where((method) => method.isDefault).firstOrNull,
    orElse: () => null,
  );
});

class PaymentMethodsNotifier extends StateNotifier<AsyncValue<List<SavedPaymentMethod>>> {
  PaymentMethodsNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getPaymentMethods);
  }

  Future<bool> addCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
  }) async {
    try {
      await _ref.read(paymentRepositoryProvider).addCard(
            cardholderName: cardholderName,
            cardNumber: cardNumber,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
          );
      state = AsyncValue.data(await _getPaymentMethods());
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> setDefault(String methodId) async {
    try {
      await _ref.read(paymentRepositoryProvider).setDefaultPaymentMethod(methodId);
      state = AsyncValue.data(await _getPaymentMethods());
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> delete(String methodId) async {
    try {
      await _ref.read(paymentRepositoryProvider).deletePaymentMethod(methodId);
      state = AsyncValue.data(await _getPaymentMethods());
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<List<SavedPaymentMethod>> _getPaymentMethods() {
    return _ref.read(paymentRepositoryProvider).getPaymentMethods();
  }
}

