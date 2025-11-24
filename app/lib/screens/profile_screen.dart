import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/controllers/profile_controller.dart';
import 'package:nomnom_safe/views/allergen_section.dart';
import 'package:nomnom_safe/views/profile_header.dart';
import 'package:nomnom_safe/widgets/delete_account_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        final user = controller.authProvider.currentUser;

        if (user == null) {
          return Center(child: Text('Please sign in to view your profile.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(fullName: user.fullName),
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
              AllergenSection(controller: controller),
              const SizedBox(height: 32),
              // Edit button
              ElevatedButton(
                onPressed: () async {
                  final success = await Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.editProfile);

                  if (success == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await controller.refreshUser(reloadAllergens: true);
                  }
                },
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 20),
              // Delete account button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final success = await showDeleteAccountDialog(
                    context,
                    controller,
                  );
                  if (success == true && context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                  } else if (success == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account deletion failed.")),
                    );
                  }
                },
                child: const Text('Delete Account'),
              ),
            ],
          ),
        );
      },
    );
  }
}
