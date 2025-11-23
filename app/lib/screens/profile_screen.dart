import 'package:flutter/material.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/nav/route_tracker.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  late final AllergenService _allergenService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
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
    _allergenService = AllergenService();
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
          if (user.allergies.isEmpty)
            Text(
              'No allergens selected',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            )
          else
            FutureBuilder<Map<String, String>>(
              future: _allergenService.getAllergenIdToLabelMap(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error loading allergens',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }

                final allergenMap = snapshot.data ?? {};

                return Wrap(
                  spacing: 8,
                  children: [
                    for (final allergenId in user.allergies)
                      Chip(
                        label: Text(allergenMap[allergenId] ?? allergenId),
                        onDeleted: null, // Read-only display
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 32),
          // Edit button
          ElevatedButton(
            onPressed: () {
              navigateIfNotCurrent(
                context,
                AppRoutes.editProfile,
                blockIfCurrent: [AppRoutes.editProfile],
              );
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
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
