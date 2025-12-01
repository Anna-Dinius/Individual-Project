import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_safe/nav/nav_destination.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

void main() {
  test(
    'NavDestination constructed and bottomNavDestinations contains expected routes',
    () {
      expect(bottomNavDestinations, isA<List<NavDestination>>());
      expect(bottomNavDestinations.length, greaterThanOrEqualTo(1));

      final routes = bottomNavDestinations.map((d) => d.route).toList();
      expect(routes, containsAll([AppRoutes.home, AppRoutes.profile]));

      final first = bottomNavDestinations.first;
      expect(first.route, AppRoutes.home);
      expect(first.label, isNotEmpty);
      expect(first.icon, isA<Icon>());
    },
  );
}
