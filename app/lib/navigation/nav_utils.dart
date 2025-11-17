import 'package:flutter/material.dart';
import 'package:nomnom_safe/navigation/route_constants.dart';

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
  List<String> blockIfCurrent = const [],
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;

  if (currentRoute != targetRoute && !blockIfCurrent.contains(currentRoute)) {
    Navigator.of(context).pushReplacementNamed(targetRoute);
  }
}

int getNavIndexForRoute(String? routeName) {
  switch (routeName) {
    case AppRoutes.home:
      return 0;
    case AppRoutes.menu:
      return 1;
    case AppRoutes.restaurant:
      return 2;
    case AppRoutes.signIn:
      return 3;
    case AppRoutes.signUp:
      return 4;
    case AppRoutes.profile:
      return 5;
    case AppRoutes.editProfile:
      return 6;
    default:
      return 0;
  }
}
