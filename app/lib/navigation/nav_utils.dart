import 'package:flutter/material.dart';
import 'package:nomnom_safe/navigation/nav_destination.dart';

void navigateIfNotCurrent(
  BuildContext context,
  String targetRoute, {
  Object? arguments,
  List<String> blockIfCurrent = const [],
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;

  if (currentRoute != targetRoute && !blockIfCurrent.contains(currentRoute)) {
    Navigator.of(context).pushNamed(targetRoute, arguments: arguments);
  }
}

void replaceIfNotCurrent(
  BuildContext context,
  String targetRoute, {
  Object? arguments,
  List<String> blockIfCurrent = const [],
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;

  if (currentRoute != targetRoute && !blockIfCurrent.contains(currentRoute)) {
    Navigator.of(
      context,
    ).pushReplacementNamed(targetRoute, arguments: arguments);
  }
}

int getNavIndexForRoute(String? routeName) {
  final index = bottomNavDestinations.indexWhere((d) => d.route == routeName);
  return index >= 0 ? index : 0;
}
