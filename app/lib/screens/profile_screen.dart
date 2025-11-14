import 'package:flutter/material.dart';
import '../widgets/nomnom_safe_appbar.dart';
import '../services/allergen_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';
import '../navigation/route_tracker.dart';

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
    currentRouteName = '/profile';
  }

  @override
  void didPopNext() {
    currentRouteName = '/profile';
  }

  @override
  void initState() {
    super.initState();
    _allergenService = AllergenService();
  }

  @override
  Widget build(BuildContext context) {
    final authStateProvider = Provider.of<AuthStateProvider>(context);
    final user = authStateProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: const NomnomSafeAppBar(title: 'Profile'),
        body: const Center(child: Text('Please sign in to view your profile')),
      );
    }

    return Scaffold(
      appBar: const NomnomSafeAppBar(title: 'Profile'),
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
                    return const CircularProgressIndicator();
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
              onPressed: () async {
                await Navigator.of(
                  context,
                ).pushNamed('/edit-profile'); // Wait for user to return
                await authStateProvider.loadCurrentUser(); // Refresh user data
                if (mounted) setState(() {}); // Trigger rebuild
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
