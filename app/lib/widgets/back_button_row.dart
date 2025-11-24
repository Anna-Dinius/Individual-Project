import 'package:flutter/material.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

class BackButtonRow extends StatelessWidget {
  const BackButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => replaceIfNotCurrent(
          context,
          AppRoutes.profile,
          blockIfCurrent: [AppRoutes.profile],
        ),
        tooltip: 'Back',
      ),
    );
  }
}
