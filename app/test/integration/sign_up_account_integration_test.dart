import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/sign_up_account_view.dart';

void main() {
  testWidgets('SignUpAccountView validates and calls onNext', (
    WidgetTester tester,
  ) async {
    bool nextCalled = false;

    final first = TextEditingController();
    final last = TextEditingController();
    final email = TextEditingController();
    final pass = TextEditingController();
    final confirm = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignUpAccountView(
            formKey: GlobalKey<FormState>(),
            firstNameController: first,
            lastNameController: last,
            emailController: email,
            passwordController: pass,
            confirmPasswordController: confirm,
            isLoading: false,
            errorMessage: null,
            onNext: () => nextCalled = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Submit with empty fields -> validation shows SnackBar and does not call next
    await tester.tap(find.text('Next: Select Allergens'));
    await tester.pumpAndSettle();
    expect(nextCalled, isFalse);

    // Fill valid data
    await tester.enterText(find.byType(TextFormField).at(0), 'A');
    await tester.enterText(find.byType(TextFormField).at(1), 'B');
    await tester.enterText(find.byType(TextFormField).at(2), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'password');
    await tester.enterText(find.byType(TextFormField).at(4), 'password');

    await tester.tap(find.text('Next: Select Allergens'));
    await tester.pumpAndSettle();

    expect(nextCalled, isTrue);
  });
}
