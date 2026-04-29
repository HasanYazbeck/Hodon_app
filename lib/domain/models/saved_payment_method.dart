import '../enums/app_enums.dart';

class SavedPaymentMethod {
  final String id;
  final PaymentMethod type;
  final bool isDefault;
  final String nickname;
  final String? cardholderName;
  final String? cardBrand;
  final String? last4;
  final int? expiryMonth;
  final int? expiryYear;
  final double? walletBalance;
  final DateTime createdAt;

  const SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.nickname,
    required this.createdAt,
    this.isDefault = false,
    this.cardholderName,
    this.cardBrand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.walletBalance,
  });

  bool get canDelete => type == PaymentMethod.card;

  String get displayTitle => switch (type) {
        PaymentMethod.card => '${cardBrand ?? 'Card'} •••• ${last4 ?? '0000'}',
        PaymentMethod.cash => nickname,
        PaymentMethod.wallet => nickname,
      };

  String get displaySubtitle => switch (type) {
        PaymentMethod.card => _cardSubtitle,
        PaymentMethod.cash => 'Pay your sitter directly after the booking',
        PaymentMethod.wallet => 'Available balance \$${(walletBalance ?? 0).toStringAsFixed(2)}',
      };

  String get _cardSubtitle {
    final parts = <String>[
      if (cardholderName != null && cardholderName!.trim().isNotEmpty)
        cardholderName!.trim(),
      if (expiryMonth != null && expiryYear != null)
        'Expires ${expiryMonth!.toString().padLeft(2, '0')}/$expiryYear',
    ];
    return parts.join(' · ');
  }

  SavedPaymentMethod copyWith({
    bool? isDefault,
    String? nickname,
    String? cardholderName,
    String? cardBrand,
    String? last4,
    int? expiryMonth,
    int? expiryYear,
    double? walletBalance,
  }) =>
      SavedPaymentMethod(
        id: id,
        type: type,
        isDefault: isDefault ?? this.isDefault,
        nickname: nickname ?? this.nickname,
        cardholderName: cardholderName ?? this.cardholderName,
        cardBrand: cardBrand ?? this.cardBrand,
        last4: last4 ?? this.last4,
        expiryMonth: expiryMonth ?? this.expiryMonth,
        expiryYear: expiryYear ?? this.expiryYear,
        walletBalance: walletBalance ?? this.walletBalance,
        createdAt: createdAt,
      );
}

