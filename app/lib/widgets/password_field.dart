import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final bool enabled;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: enabled ? onToggleVisibility : null,
          tooltip: isVisible ? 'Hide password' : 'Show password',
        ),
      ),
    );
  }
}
