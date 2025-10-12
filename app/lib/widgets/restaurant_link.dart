import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import '../theme/theme_constants.dart';

/* A widget that displays a clickable link to a restaurant's website */
class RestaurantLink extends StatelessWidget {
  final String url; // URL provided by restaurant
  final String? label; // Optional label to display instead of URL
  final EdgeInsetsGeometry? padding; // Optional padding around the link

  const RestaurantLink({
    super.key,
    required this.url,
    this.label,
    this.padding,
  });

  /* Normalize URL to ensure it has a scheme */
  Uri _normalizeUrl(String url) {
    final hasScheme = url.startsWith(RegExp(r'https?://'));
    return Uri.parse(hasScheme ? url : 'https://$url');
  }

  @override
  Widget build(BuildContext context) {
    // Validate and normalize the URL
    Uri? uri;
    try {
      uri = _normalizeUrl(url);
    } catch (_) {}

    if (uri == null) {
      return const Text('Invalid URL');
    }

    final safeUri = uri;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Link(
        uri: safeUri,
        target: LinkTarget.blank,
        builder: (context, followLink) => TextButton(
          onPressed: followLink,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the label or the host part of the URL
              Text(
                label ?? safeUri.host,
                style: NomNomThemeConstants.linkTextStyle(),
              ),
              // Icon indicating the link opens in a new tab
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: const IconTheme(
                  data: IconThemeData(
                    color: NomNomThemeConstants.linkBlue,
                    size: NomNomThemeConstants.linkIconSize,
                  ),
                  child: Icon(Icons.open_in_new),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
