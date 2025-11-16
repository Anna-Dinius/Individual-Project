import 'package:flutter/material.dart';
import '../widgets/nomnom_appbar.dart';
import '../navigation/route_tracker.dart';
import '../views/sign_up_account_view.dart';
import '../views/sign_up_allergen_view.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with RouteAware {
  bool _showAllergenView = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Shared state variables
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> selectedAllergenIds = [];

  void _goToAllergenView() => setState(() => _showAllergenView = true);
  void _goBackToAccountView() => setState(() => _showAllergenView = false);

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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        allergies: selectedAllergenIds,
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
    final viewTitle = _showAllergenView ? 'Select Allergens' : 'Create Account';

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
            viewTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _showAllergenView
              ? SignUpAllergenView(
                  isLoading: _isLoading,
                  selectedAllergenIds: selectedAllergenIds,
                  onChanged: (ids) => setState(() => selectedAllergenIds = ids),
                  onBack: _goBackToAccountView,
                  onSubmit: _handleSignUp,
                )
              : SignUpAccountView(
                  formKey: _formKey,
                  firstNameController: firstNameController,
                  lastNameController: lastNameController,
                  emailController: emailController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  onNext: _goToAllergenView,
                ),
        ],
      ),
    );
  }
}
