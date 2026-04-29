import '../../../domain/enums/app_enums.dart';
import '../../../domain/models/saved_payment_method.dart';
import '../interfaces/i_payment_repository.dart';

class MockPaymentRepository implements IPaymentRepository {
  final List<SavedPaymentMethod> _methods = [
    SavedPaymentMethod(
      id: 'pm_card_1',
      type: PaymentMethod.card,
      nickname: 'Personal Visa',
      cardholderName: 'Sara Khalil',
      cardBrand: 'Visa',
      last4: '4242',
      expiryMonth: 8,
      expiryYear: 2028,
      isDefault: true,
      createdAt: DateTime(2025, 8, 18),
    ),
    SavedPaymentMethod(
      id: 'pm_wallet_1',
      type: PaymentMethod.wallet,
      nickname: 'Hodon Wallet',
      walletBalance: 86.50,
      createdAt: DateTime(2025, 9, 6),
    ),
    SavedPaymentMethod(
      id: 'pm_cash_1',
      type: PaymentMethod.cash,
      nickname: 'Cash',
      createdAt: DateTime(2025, 7, 11),
    ),
    SavedPaymentMethod(
      id: 'pm_card_2',
      type: PaymentMethod.card,
      nickname: 'Backup Mastercard',
      cardholderName: 'Sara Khalil',
      cardBrand: 'Mastercard',
      last4: '5584',
      expiryMonth: 11,
      expiryYear: 2027,
      createdAt: DateTime(2025, 10, 2),
    ),
  ];

  @override
  Future<List<SavedPaymentMethod>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _sortedMethods();
  }

  @override
  Future<SavedPaymentMethod> addCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final digitsOnly = cardNumber.replaceAll(RegExp(r'\D'), '');
    final last4 = digitsOnly.length >= 4 ? digitsOnly.substring(digitsOnly.length - 4) : digitsOnly.padLeft(4, '0');
    final card = SavedPaymentMethod(
      id: 'pm_card_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentMethod.card,
      nickname: '${_detectBrand(digitsOnly)} Card',
      cardholderName: cardholderName.trim(),
      cardBrand: _detectBrand(digitsOnly),
      last4: last4,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      createdAt: DateTime.now(),
    );

    _methods.add(card);
    return card;
  }

  @override
  Future<void> setDefaultPaymentMethod(String methodId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final exists = _methods.any((method) => method.id == methodId);
    if (!exists) throw Exception('Payment method not found.');

    for (var i = 0; i < _methods.length; i++) {
      final method = _methods[i];
      _methods[i] = method.copyWith(isDefault: method.id == methodId);
    }
  }

  @override
  Future<void> deletePaymentMethod(String methodId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _methods.indexWhere((method) => method.id == methodId);
    if (index == -1) throw Exception('Payment method not found.');

    final target = _methods[index];
    if (!target.canDelete) {
      throw Exception('This payment method cannot be removed.');
    }

    final wasDefault = target.isDefault;
    _methods.removeAt(index);

    if (wasDefault && _methods.isNotEmpty) {
      final fallbackIndex = _methods.indexWhere((method) => method.type == PaymentMethod.card);
      final newDefaultIndex = fallbackIndex >= 0 ? fallbackIndex : 0;
      for (var i = 0; i < _methods.length; i++) {
        _methods[i] = _methods[i].copyWith(isDefault: i == newDefaultIndex);
      }
    }
  }

  List<SavedPaymentMethod> _sortedMethods() {
    final methods = [..._methods];
    methods.sort((a, b) {
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return List.unmodifiable(methods);
  }

  String _detectBrand(String digitsOnly) {
    if (digitsOnly.startsWith('4')) return 'Visa';
    if (digitsOnly.startsWith('5')) return 'Mastercard';
    if (digitsOnly.startsWith('3')) return 'Amex';
    return 'Card';
  }
}

