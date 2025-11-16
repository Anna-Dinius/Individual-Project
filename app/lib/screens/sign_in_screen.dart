import 'package:flutter/material.dart';
import 'package:nomnom_safe/utils/auth_utils.dart';
import 'package:nomnom_safe/widgets/text_form_field_with_controller.dart';
import '../widgets/nomnom_appbar.dart';
import '../navigation/route_tracker.dart';
import '../widgets/password_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with RouteAware {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    // Unsubscribe from route observer
    routeObserver.unsubscribe(this);

    // Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    currentRouteName = '/sign-in';
  }

  @override
  void didPopNext() {
    currentRouteName = '/sign-in';
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await authStateProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Pop back to home screen and trigger AppBar rebuild
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withAlpha(25),
                border: Border.all(color: Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_errorMessage != null) const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormFieldWithController(
                  controller: _emailController,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: validateEmailFormat,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  isRequired: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              TextButton(
                onPressed: () {
                  if (currentRouteName != '/sign-up') {
                    Navigator.of(context).pushReplacementNamed('/sign-up');
                  }
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
