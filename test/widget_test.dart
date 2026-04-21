import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hodon_app/app.dart';

void main() {
  testWidgets('Hodon app boots and shows splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HodonApp(),
      ),
    );

    // Initial route is splash.
    expect(find.text('Hodon'), findsOneWidget);
    expect(find.text('Trusted Childcare, Near You'), findsOneWidget);

    // Let splash delayed auth check timer complete to avoid pending timer assertion.
    await tester.pump(const Duration(seconds: 2));
  });
}
