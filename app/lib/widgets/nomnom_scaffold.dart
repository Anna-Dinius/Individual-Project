import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';
import 'package:nomnom_safe/utils/navigation_utils.dart';

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
    final routeName = ModalRoute.of(context)?.settings.name;
    final currentIndex = getNavIndexForRoute(routeName);

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: user != null
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                if (index == 0) {
                  replaceIfNotCurrent(context, '/home');
                } else if (index == 1) {
                  replaceIfNotCurrent(
                    context,
                    '/profile',
                    blockIfCurrent: ['/profile'],
                  );
                }
              },
            )
          : null,
    );
  }
}
