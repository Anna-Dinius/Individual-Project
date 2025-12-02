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

  testWidgets('RestaurantLink normalizes URL without scheme and shows host', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RestaurantLink(url: 'example.com')),
      ),
    );
    // RestaurantLink displays the host (example.com) inside a TextButton
    expect(find.text('example.com'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('RestaurantLink handles invalid URL gracefully', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RestaurantLink(url: 'ht!tp://@@@')),
      ),
    );
    // Uri.parse is permissive; the widget should not throw and should render a button
    expect(find.byType(TextButton), findsOneWidget);
  });
}
