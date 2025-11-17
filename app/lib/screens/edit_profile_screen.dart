import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/utils/allergen_utils.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/navigation/route_tracker.dart';
import 'package:nomnom_safe/views/edit_profile_view.dart';
import 'package:nomnom_safe/views/verify_current_password_view.dart';
import 'package:nomnom_safe/views/update_password_view.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/navigation/route_constants.dart';
import 'package:nomnom_safe/navigation/nav_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

enum ProfileViewState { editProfile, verifyCurrentPassword, updatePassword }

class _EditProfileScreenState extends State<EditProfileScreen> with RouteAware {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  late AuthStateProvider _authProvider;
  late EditProfileController _controller;
  bool _isLoading = false;
  String? _errorMessage;
  bool _arePasswordsVisible = false;
  List<Allergen> _allAllergens = []; // full list from DB
  Set<String> _selectedAllergenIds = {}; // store selected allergen IDs
  ProfileViewState _viewState = ProfileViewState.editProfile;

  // Service classes
  final AllergenService _allergenService = AllergenService();

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
    currentRouteName = AppRoutes.editProfile;
  }

  @override
  void didPopNext() {
    currentRouteName = AppRoutes.editProfile;
  }

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthStateProvider>();
    _controller = EditProfileController(authProvider: _authProvider);

    final user = _authProvider.currentUser;
    if (user != null) {
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _emailController = TextEditingController(text: user.email);
      _selectedAllergenIds = user.allergies.toSet();
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _emailController = TextEditingController();
    }

    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Load allergens when the widget is first built
    _fetchAllergens();
  }

  /* Fetch allergen labels and update the state if the widget is still mounted */
  void _fetchAllergens() async {
    final allergens = await _allergenService.getAllergens();
    if (mounted) {
      setState(() {
        _allAllergens = allergens;
      });
    }
  }

  void _handleAllergenChanged(String label, bool checked) {
    final matching = _allAllergens.firstWhere((a) => a.label == label);

    setState(() {
      if (checked) {
        _selectedAllergenIds.add(matching.id);
      } else {
        _selectedAllergenIds.remove(matching.id);
      }
    });
  }

  Future<void> _handleSaveChanges() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // Stop if form is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors before saving')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _controller.saveProfileChanges(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      allergies: _selectedAllergenIds.toList(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });

      if (error == null) {
        replaceIfNotCurrent(
          context,
          AppRoutes.profile,
          blockIfCurrent: [AppRoutes.profile, AppRoutes.editProfile],
        );
      }
    }
  }

  Future<void> _handleVerifyCurrentPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _controller.verifyCurrentPassword(
      _currentPasswordController.text,
    );

    setState(() {
      _isLoading = false;
      _viewState = success
          ? ProfileViewState.updatePassword
          : ProfileViewState.verifyCurrentPassword;
      _errorMessage = success ? null : 'Incorrect password';
    });
  }

  Future<void> _handleUpdatePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _controller.updatePassword(
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmNewPasswordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        setState(() {
          _viewState = ProfileViewState.editProfile;
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  Widget _buildCurrentView() {
    switch (_viewState) {
      case ProfileViewState.editProfile:
        return EditProfileView(
          formKey: _formKey,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          emailController: _emailController,
          onSave: _handleSaveChanges,
          onChangePassword: () {
            setState(() => _viewState = ProfileViewState.verifyCurrentPassword);
          },
          isLoading: _isLoading,
          allAllergenLabels: extractAllergenLabels(_allAllergens),
          selectedAllergenLabels: _allAllergens
              .where((a) => _selectedAllergenIds.contains(a.id))
              .map((a) => a.label)
              .toSet(),
          onAllergenChanged: _handleAllergenChanged,
        );
      case ProfileViewState.verifyCurrentPassword:
        return VerifyCurrentPasswordView(
          controller: _currentPasswordController,
          isVisible: _arePasswordsVisible,
          onToggleVisibility: () {
            setState(() => _arePasswordsVisible = !_arePasswordsVisible);
          },
          onContinue: _handleVerifyCurrentPassword,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
        );
      case ProfileViewState.updatePassword:
        return UpdatePasswordView(
          formKey: _formKey,
          newPasswordController: _newPasswordController,
          confirmPasswordController: _confirmNewPasswordController,
          isVisible: _arePasswordsVisible,
          onToggleVisibility: () {
            setState(() => _arePasswordsVisible = !_arePasswordsVisible);
          },
          onBack: () {
            setState(() => _viewState = ProfileViewState.editProfile);
          },
          onSubmit: _handleUpdatePassword,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => replaceIfNotCurrent(
                context,
                AppRoutes.profile,
                blockIfCurrent: [AppRoutes.profile, AppRoutes.editProfile],
              ),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null &&
              _viewState != ProfileViewState.verifyCurrentPassword)
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
          _buildCurrentView(),
        ],
      ),
    );
  }
}
