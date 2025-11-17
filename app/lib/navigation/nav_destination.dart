import 'package:flutter/material.dart';
import 'package:nomnom_safe/navigation/route_constants.dart';

class NavDestination {
  final String route;
  final Icon icon;
  final String label;

  const NavDestination({
    required this.route,
    required this.icon,
    required this.label,
  });
}

const List<NavDestination> bottomNavDestinations = [
  NavDestination(
    route: AppRoutes.home,
    icon: Icon(Icons.search),
    label: 'Search',
  ),
  NavDestination(
    route: AppRoutes.profile,
    icon: Icon(Icons.person),
    label: 'Profile',
  ),
];
