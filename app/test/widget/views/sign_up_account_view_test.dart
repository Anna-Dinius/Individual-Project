import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/sign_up_account_view.dart';

void main() {
  testWidgets('SignUpAccountView renders and Next button present', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final fn = TextEditingController();
    final ln = TextEditingController();
    final email = TextEditingController();
    final pass = TextEditingController();
    final conf = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpAccountView(
            formKey: formKey,
            firstNameController: fn,
            lastNameController: ln,
            emailController: email,
            passwordController: pass,
            confirmPasswordController: conf,
            isLoading: false,
            errorMessage: null,
            onNext: () {},
          ),
        ),
      ),
    );

    expect(find.text('Next: Select Allergens'), findsOneWidget);
  });
}
