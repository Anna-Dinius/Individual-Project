import 'package:flutter/material.dart';
import 'package:nomnom_safe/controllers/profile_controller.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';

Future<bool?> showDeleteAccountDialog(
  BuildContext context,
  ProfileController controller,
) {
  final formKey = GlobalKey<FormState>();

  return showDialog<bool>(
    context: context,
    builder: (_) {
      final passwordController = TextEditingController();

      return AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your password to confirm account deletion.'),
              const SizedBox(height: 12),
              TextFormFieldWithController(
                controller: passwordController,
                label: 'Password',
                obscureText: true,
                isRequired: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Run validation before attempting deletion
              if (formKey.currentState!.validate()) {
                final success = await controller.deleteAccount(
                  passwordController.text,
                );
                Navigator.pop(context, success); // return true/false directly
              }
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
