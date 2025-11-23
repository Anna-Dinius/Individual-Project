import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/nav/nav_destination.dart';

class NomNomScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final int? currentIndex;

  const NomNomScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthStateProvider>().currentUser;
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final currentIndex = getNavIndexForRoute(currentRoute);

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: user != null
          ? BottomNavigationBar(
              currentIndex: currentIndex >= 0 ? currentIndex : 0,
              items: bottomNavDestinations
                  .map(
                    (d) =>
                        BottomNavigationBarItem(icon: d.icon, label: d.label),
                  )
                  .toList(),
              onTap: (index) {
                final destination = bottomNavDestinations[index];
                replaceIfNotCurrent(
                  context,
                  destination.route,
                  blockIfCurrent: destination.route == AppRoutes.profile
                      ? [AppRoutes.profile, AppRoutes.editProfile]
                      : [],
                );
              },
            )
          : null,
    );
  }
}
