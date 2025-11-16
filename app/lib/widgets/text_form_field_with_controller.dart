import 'package:flutter/material.dart';

class TextFormFieldWithController extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool isRequired;
  final Widget? suffixIcon;

  const TextFormFieldWithController({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.isRequired = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = isRequired ? '$label *' : label;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: displayLabel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
