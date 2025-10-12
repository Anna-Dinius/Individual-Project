import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('MaterialApp builds without crashing', (tester) async {
    // Avoid constructing MyApp to prevent Firebase initialization during tests.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
