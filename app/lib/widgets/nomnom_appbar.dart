import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

/* Custom AppBar widget for consistency across the app */
class NomnomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const NomnomAppBar({super.key, this.title = 'Nomnom Safe'});

  void _handleSignOut(BuildContext context) async {
    final authStateProvider = context.read<AuthStateProvider>();
    await authStateProvider.signOut();

    if (context.mounted) {
      // Navigate back to home
      replaceIfNotCurrent(
        context,
        AppRoutes.home,
        blockIfCurrent: [AppRoutes.home],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = context.watch<AuthStateProvider>().isSignedIn;

    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false, // Disable automatic back arrow
      actions: [
        if (isSignedIn) ...[
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
            onPressed: () => navigateIfNotCurrent(
              context,
              AppRoutes.signIn,
              blockIfCurrent: [AppRoutes.signIn],
            ),
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
          // Sign Up button
          TextButton(
            onPressed: () => navigateIfNotCurrent(
              context,
              AppRoutes.signUp,
              blockIfCurrent: [AppRoutes.signUp],
            ),
            child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
