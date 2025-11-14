import 'package:flutter/material.dart';
import '../providers/auth_state_provider.dart';

/// Global instance of AuthStateProvider to be used throughout the app
final authStateProvider = AuthStateProvider();

/* Custom AppBar widget for consistency across the app */
class NomnomSafeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const NomnomSafeAppBar({super.key, this.title = 'Nomnom Safe'});

  void _handleSignOut(BuildContext context) async {
    await authStateProvider.signOut();
    if (context.mounted) {
      // Navigate back to home
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authStateProvider,
      builder: (context, _) {
        final isSignedIn = authStateProvider.isSignedIn;

        return AppBar(
          title: Text(title),
          automaticallyImplyLeading: false, // Disable automatic back arrow
          actions: [
            if (isSignedIn) ...[
              // Profile button
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                tooltip: 'Profile',
              ),
              // Sign Out button
              TextButton(
                onPressed: () => _handleSignOut(context),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ] else ...[
              // Sign In button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/sign-in');
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // Sign Up button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/sign-up');
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
