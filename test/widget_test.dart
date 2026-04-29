import 'package:flutter/material.dart';
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

    // Initial route is splash with brand logo.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/icons/Hodon_Logo.png',
      ),
      findsOneWidget,
    );

    // Let splash delayed auth check timer complete to avoid pending timer assertion.
    await tester.pump(const Duration(seconds: 2));
  });
}
