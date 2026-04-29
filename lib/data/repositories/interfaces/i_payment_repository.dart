import '../../../domain/models/saved_payment_method.dart';

abstract class IPaymentRepository {
  Future<List<SavedPaymentMethod>> getPaymentMethods();

  Future<SavedPaymentMethod> addCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
  });

  Future<void> setDefaultPaymentMethod(String methodId);

  Future<void> deletePaymentMethod(String methodId);
}

