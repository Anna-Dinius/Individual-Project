import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class RestaurantLink extends StatelessWidget {
  final String url;

  const RestaurantLink({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Link(
        uri: Uri.parse(url.startsWith('http') ? url : 'https://$url'),
        target: LinkTarget.blank,
        builder: (context, followLink) => TextButton(
          onPressed: followLink,
          child: Text(
            url,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
