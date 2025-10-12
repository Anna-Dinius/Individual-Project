import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/restaurant_link.dart';

void main() {
  testWidgets('RestaurantLink displays host for http url', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RestaurantLink(url: 'https://example.com')),
      ),
    );
    expect(find.text('example.com'), findsOneWidget);
  });

  testWidgets('RestaurantLink shows Invalid URL for bad url', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RestaurantLink(url: '::bad::')),
      ),
    );
    expect(find.text('Invalid URL'), findsOneWidget);
  });
}
