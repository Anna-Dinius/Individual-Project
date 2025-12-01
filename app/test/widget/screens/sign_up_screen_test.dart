import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/screens/sign_up_screen.dart';

void main() {
  testWidgets('SignUpScreen initial view shows Create Account', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SignUpScreen())));

    expect(find.text('Create Account'), findsOneWidget);
  });
}
