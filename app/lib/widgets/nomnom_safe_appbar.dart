import 'package:flutter/material.dart';

/* Custom AppBar widget for consistency across the app */
class NomnomSafeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const NomnomSafeAppBar({super.key, this.title = 'Nomnom Safe'});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
