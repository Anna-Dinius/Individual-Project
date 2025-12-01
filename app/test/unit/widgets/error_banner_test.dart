import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';

void main() {
  testWidgets('ErrorBanner displays provided message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ErrorBanner('Something went wrong'))),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
  });
}
