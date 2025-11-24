import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/nav/route_tracker.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/services/service_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  late AllergenService _allergenService;

  Map<String, String> allergenIdToLabel = {};
  Set<String> _selectedAllergenLabels = {};
  bool isLoadingAllergens = true;
  String? allergenError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    _allergenService = getAllergenService(context);

    if (allergenIdToLabel.isEmpty && isLoadingAllergens) {
      _fetchAllergens();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    currentRouteName = AppRoutes.profile;
  }

  @override
  void didPopNext() {
    currentRouteName = AppRoutes.profile;
    context.read<AuthStateProvider>().loadCurrentUser().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchAllergens() async {
    try {
      final idToLabel = await _allergenService.getAllergenIdToLabelMap();
      final user = context.read<AuthStateProvider>().currentUser;
      final selectedLabels = user != null
          ? await _allergenService.idsToLabels(user.allergies)
          : <String>[];

      if (mounted) {
        setState(() {
          allergenIdToLabel = idToLabel;
          _selectedAllergenLabels = selectedLabels.toSet();
          isLoadingAllergens = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          allergenError = "Error loading allergens.";
          isLoadingAllergens = false;
        });
      }
    }
  }

  Widget _buildAllergenSection() {
    if (isLoadingAllergens) {
      return const Center(child: CircularProgressIndicator());
    }
    if (allergenError != null) {
      return Text(
        '$allergenError',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    if (_selectedAllergenLabels.isEmpty) {
      return Text(
        'No allergens selected',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
      );
    }
    return Wrap(
      spacing: 8,
      children: [
        for (final label in _selectedAllergenLabels)
          Chip(
            label: Text(label),
            onDeleted: null, // read-only
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authStateProvider = context.read<AuthStateProvider>();
    final user = authStateProvider.currentUser;

    if (user == null) {
      return Center(child: Text('Please sign in to view your profile'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile icon
          Center(
            child: Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          // Full name
          Center(
            child: Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Divider
          Divider(thickness: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 24),
          // Email
          Text('Email', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          // Allergies
          Text(
            'Selected Allergens',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildAllergenSection(),
          const SizedBox(height: 32),
          // Edit button
          ElevatedButton(
            onPressed: () async {
              final success = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.editProfile);

              if (success == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully.'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Refresh user data if needed
                await context.read<AuthStateProvider>().loadCurrentUser();
                setState(() {});
              }
            },

            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final passwordController = TextEditingController();

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Account Deletion'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enter your password to confirm account deletion.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final authStateProvider = context.read<AuthStateProvider>();

                try {
                  await authStateProvider.deleteAccount(
                    password: passwordController.text,
                  );
                  if (mounted) {
                    replaceIfNotCurrent(
                      context,
                      AppRoutes.home,
                      blockIfCurrent: [AppRoutes.home],
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Account deletion failed.")),
                  );
                }
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
