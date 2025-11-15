import 'package:flutter/material.dart';
import '../widgets/nomnom_safe_appbar.dart';
import '../navigation/route_tracker.dart';
import '../widgets/password_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with RouteAware {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _arePasswordsVisible = false;
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    currentRouteName = '/sign-up';
  }

  @override
  void didPopNext() {
    currentRouteName = '/sign-up';
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await authStateProvider.signUp(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
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
    return Scaffold(
      appBar: const NomnomSafeAppBar(title: 'Sign Up'),
      body: SingleChildScrollView(
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
              'Create Account',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withAlpha(25),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              label: 'Password',
              isVisible: _arePasswordsVisible,
              onToggleVisibility: () {
                setState(() {
                  _arePasswordsVisible = !_arePasswordsVisible;
                });
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              isVisible: _arePasswordsVisible,
              onToggleVisibility: () {
                setState(() {
                  _arePasswordsVisible = !_arePasswordsVisible;
                });
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignUp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign Up'),
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () {
                      if (currentRouteName != '/sign-in') {
                        Navigator.of(context).pushReplacementNamed('/sign-in');
                      }
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
