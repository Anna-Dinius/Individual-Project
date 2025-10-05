import '../models/entities/restaurant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantService {
  final FirebaseFirestore _firestore;

  RestaurantService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Restaurant>> getFilteredRestaurants(
    List<String> selectedAllergenIds,
    List<Restaurant> allRestaurants,
  ) async {
    // If no allergens are selected, return all restaurants unfiltered
    if (selectedAllergenIds.isEmpty) return allRestaurants;

    // Initialize an empty list to collect restaurants that are safe for the user.
    List<Restaurant> safeRestaurants = [];

    // Iterate over each restaurant to evaluate its menu items.
    for (final restaurant in allRestaurants) {
      // Query Firestore for the menu associated with the current restaurant.
      final menuSnapshot = await _firestore
          .collection('menus')
          .where('restaurant_id', isEqualTo: restaurant.id)
          .limit(1)
          .get();

      // Skip this restaurant if no menu is found.
      if (menuSnapshot.docs.isEmpty) continue;

      // Extract the ID of the found menu.
      final menuId = menuSnapshot.docs.first.id;

      // Query Firestore for all menu items linked to that menu.
      final menuItemsSnapshot = await _firestore
          .collection('menu_items')
          .where('menu_id', isEqualTo: menuId)
          .get();

      // Maps each menu item to its list of allergens, defaulting to an empty list if none are present.
      final menuItems = menuItemsSnapshot.docs.map((doc) {
        final data = doc.data();
        return List<String>.from(data['allergens'] ?? []);
      }).toList();

      // Check if every menu item contains at least one of the selected allergens.
      final allItemsUnsafe = menuItems.every(
        (itemAllergens) => selectedAllergenIds.any(
          (selected) => itemAllergens.contains(selected),
        ),
      );

      // Add the restaurant to the safe list if at least one menu item is allergen-free.
      if (!allItemsUnsafe) {
        safeRestaurants.add(restaurant);
      }
    }

    // Return the filtered list of safe restaurants.
    return safeRestaurants;
  }
}
