import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';

void main() {
  testWidgets(
    'TextFormFieldWithController shows required marker and validator',
    (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormFieldWithController(
              controller: controller,
              label: 'Name',
              isRequired: true,
            ),
          ),
        ),
      );

      // Label should include asterisk
      expect(find.text('Name *'), findsOneWidget);

      // Try validating empty field via a Form
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormFieldWithController(
                controller: controller,
                label: 'Name',
                isRequired: true,
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState?.validate(), isFalse);
    },
  );
}
