import 'package:flutter/material.dart';
import '../widgets/nomnom_safe_appbar.dart';
import '../providers/auth_state_provider.dart';
import '../navigation/route_tracker.dart';
import '../widgets/password_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with RouteAware {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late AuthStateProvider _authProvider;
  bool _isLoading = false;
  String? _errorMessage;
  bool _arePasswordsVisible = false;

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
    currentRouteName = '/edit-profile';
  }

  @override
  void didPopNext() {
    currentRouteName = '/edit-profile';
  }

  @override
  void initState() {
    super.initState();
    _authProvider = AuthStateProvider();
    final user = _authProvider.currentUser;
    if (user != null) {
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _emailController = TextEditingController(text: user.email);
      _passwordController = TextEditingController();
      _confirmPasswordController = TextEditingController();
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _emailController = TextEditingController();
      _passwordController = TextEditingController();
      _confirmPasswordController = TextEditingController();
    }
  }

  Future<void> _handleSaveChanges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
          _isLoading = false;
        });
        return;
      }

      await _authProvider.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        allergies: _authProvider.currentUser?.allergies,
      );
      await _authProvider.loadCurrentUser();

      if (mounted) {
        Navigator.of(context).pop();
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
      appBar: const NomnomSafeAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSaveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
