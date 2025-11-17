import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/password_field.dart';

class VerifyCurrentPasswordView extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onContinue;
  final bool isLoading;
  final String? errorMessage;

  const VerifyCurrentPasswordView({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onContinue,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter Current Password',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withAlpha(25),
              border: Border.all(color: Theme.of(context).colorScheme.error),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (errorMessage != null) const SizedBox(height: 16),
        PasswordField(
          controller: controller,
          label: 'Current Password',
          isVisible: isVisible,
          isRequired: true,
          onToggleVisibility: onToggleVisibility,
          enabled: !isLoading,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isLoading ? null : onContinue,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }
}
