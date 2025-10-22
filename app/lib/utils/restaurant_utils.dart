import 'package:nomnom_safe/models/restaurant.dart';

List<String> extractAvailableCuisines(List<Restaurant> restaurants) {
  final cuisines = restaurants.map((r) => r.cuisine).toSet().toList();
  cuisines.sort(); // Sort alphabetically
  return cuisines;
}

List<Restaurant> filterRestaurantsByCuisine(
  List<Restaurant> allRestaurants,
  List<String> selectedCuisines,
) {
  if (selectedCuisines.isEmpty) return allRestaurants;
  return allRestaurants
      .where((r) => selectedCuisines.contains(r.cuisine))
      .toList();
}
