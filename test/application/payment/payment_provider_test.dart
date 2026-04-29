import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodon_app/application/payment/payment_provider.dart';
import 'package:hodon_app/domain/enums/app_enums.dart';

void main() {
  test('setting a new default payment method updates the saved methods list', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(paymentMethodsProvider.notifier).load();
    final methods = container.read(paymentMethodsProvider).requireValue;
    final wallet = methods.firstWhere((method) => method.type == PaymentMethod.wallet);

    await container.read(paymentMethodsProvider.notifier).setDefault(wallet.id);

    final updatedMethods = container.read(paymentMethodsProvider).requireValue;
    final defaultMethod = updatedMethods.singleWhere((method) => method.isDefault);

    expect(defaultMethod.id, wallet.id);
    expect(defaultMethod.type, PaymentMethod.wallet);
  });

  test('deleting the default card promotes another method to default', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(paymentMethodsProvider.notifier).load();
    final methods = container.read(paymentMethodsProvider).requireValue;
    final defaultCard = methods.singleWhere((method) => method.isDefault);

    await container.read(paymentMethodsProvider.notifier).delete(defaultCard.id);

    final updatedMethods = container.read(paymentMethodsProvider).requireValue;

    expect(updatedMethods.any((method) => method.id == defaultCard.id), isFalse);
    expect(updatedMethods.where((method) => method.isDefault).length, 1);
  });
}

