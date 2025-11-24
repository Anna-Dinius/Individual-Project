import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;
  const ProfileHeader({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.person,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          fullName,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Divider(thickness: 1, color: Theme.of(context).dividerColor),
        const SizedBox(height: 24),
      ],
    );
  }
}
