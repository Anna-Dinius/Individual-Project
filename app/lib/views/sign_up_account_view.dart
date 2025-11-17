import 'package:flutter/material.dart';
import 'package:nomnom_safe/utils/auth_utils.dart';
import 'package:nomnom_safe/navigation/nav_utils.dart';
import 'package:nomnom_safe/widgets/password_field.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';
import 'package:nomnom_safe/navigation/route_constants.dart';

class SignUpAccountView extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onNext;

  const SignUpAccountView({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onNext,
  });

  @override
  State<SignUpAccountView> createState() => _SignUpAccountViewState();
}

class _SignUpAccountViewState extends State<SignUpAccountView> {
  bool _arePasswordsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error Message
        if (widget.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withAlpha(25),
              border: Border.all(color: Theme.of(context).colorScheme.error),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (widget.errorMessage != null) const SizedBox(height: 16),
        Form(
          key: widget.formKey,
          child: Column(
            children: [
              TextFormFieldWithController(
                controller: widget.firstNameController,
                label: 'First Name',
                isRequired: true,
                enabled: !widget.isLoading,
              ),
              const SizedBox(height: 16),
              TextFormFieldWithController(
                controller: widget.lastNameController,
                label: 'Last Name',
                isRequired: true,
                enabled: !widget.isLoading,
              ),
              const SizedBox(height: 16),
              TextFormFieldWithController(
                controller: widget.emailController,
                label: 'Email',
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                enabled: !widget.isLoading,
                validator: validateEmailFormat,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: widget.passwordController,
                label: 'Password',
                isRequired: true,
                isVisible: _arePasswordsVisible,
                onToggleVisibility: () {
                  setState(() {
                    _arePasswordsVisible = !_arePasswordsVisible;
                  });
                },
                enabled: !widget.isLoading,
                validator: validatePasswordFormat,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: widget.confirmPasswordController,
                label: 'Confirm Password',
                isRequired: true,
                isVisible: _arePasswordsVisible,
                onToggleVisibility: () {
                  setState(() {
                    _arePasswordsVisible = !_arePasswordsVisible;
                  });
                },
                enabled: !widget.isLoading,
                validator: validatePasswordFormat,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        final isValid =
                            widget.formKey.currentState?.validate() ?? false;
                        final passwordsMatch = validatePasswordsMatch(
                          widget.passwordController.text,
                          widget.confirmPasswordController.text,
                        );

                        if (!passwordsMatch) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                            ),
                          );
                          return;
                        }

                        if (isValid) {
                          widget.onNext();
                        }
                      },
                child: const Text('Next: Select Allergens'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account? '),
            TextButton(
              onPressed: () {
                navigateIfNotCurrent(
                  context,
                  AppRoutes.signIn,
                  blockIfCurrent: [AppRoutes.signIn],
                );
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ],
    );
  }
}
