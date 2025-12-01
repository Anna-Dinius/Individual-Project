import 'package:flutter/material.dart';
import 'text_form_field_with_controller.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool isRequired;
  final Key? fieldKey;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.enabled,
    this.validator,
    this.isRequired = false,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormFieldWithController(
      fieldKey: fieldKey,
      controller: controller,
      obscureText: !isVisible,
      enabled: enabled,
      label: label,
      validator: validator,
      isRequired: isRequired,
      suffixIcon: IconButton(
        icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: enabled ? onToggleVisibility : null,
        tooltip: isVisible ? 'Hide password' : 'Show password',
      ),
    );
  }
}
