import 'package:flutter/material.dart';

void navigateIfNotCurrent(
  BuildContext context,
  String targetRoute, {
  List<String> blockIfCurrent = const [],
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;

  if (currentRoute != targetRoute && !blockIfCurrent.contains(currentRoute)) {
    Navigator.of(context).pushNamed(targetRoute);
  }
}
