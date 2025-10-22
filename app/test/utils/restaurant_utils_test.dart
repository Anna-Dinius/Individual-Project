import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/utils/restaurant_utils.dart';

bool _isSorted(List<String> list) {
  for (var i = 1; i < list.length; i++) {
    if (list[i - 1].compareTo(list[i]) > 0) return false;
  }
  return true;
}

void main() {
  final restaurants = [
    Restaurant.fromJson({
      'id': 'r1',
      'name': 'R1',
      'address_id': 'a1',
      'website': '',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': '',
      'cuisine': 'Italian',
      'disclaimers': [],
      'logoUrl': '',
    }),
    Restaurant.fromJson({
      'id': 'r2',
      'name': 'R2',
      'address_id': 'a2',
      'website': '',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': '',
      'cuisine': 'Mexican',
      'disclaimers': [],
      'logoUrl': '',
    }),
    Restaurant.fromJson({
      'id': 'r3',
      'name': 'R3',
      'address_id': 'a3',
      'website': '',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': '',
      'cuisine': 'italian', // lowercase to test case-sensitivity
      'disclaimers': [],
      'logoUrl': '',
    }),
    Restaurant.fromJson({
      'id': 'r4',
      'name': 'R4',
      'address_id': 'a4',
      'website': '',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': '',
      'cuisine': '  Thai ', // whitespace to test preservation
      'disclaimers': [],
      'logoUrl': '',
    }),
    Restaurant.fromJson({
      'id': 'r5',
      'name': 'R5',
      'address_id': 'a5',
      'website': '',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': '',
      'cuisine': '', // empty cuisine string edge case
      'disclaimers': [],
      'logoUrl': '',
    }),
    Restaurant.fromJson({
      'id': 'r6',
      'name': 'R6',
      'address_id': 'a6',
      'website': '',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': '',
      'cuisine': 'Mexican', // duplicate to test deduplication
      'disclaimers': [],
      'logoUrl': '',
    }),
  ];

  test(
    'extractAvailableCuisines returns unique, sorted list and preserves exact strings',
    () {
      final available = extractAvailableCuisines(restaurants);
      final expectedSet = restaurants.map((r) => r.cuisine).toSet();
      expect(available.toSet(), equals(expectedSet));
      expect(_isSorted(available), isTrue);
    },
  );

  test('extractAvailableCuisines returns empty list when no restaurants', () {
    final available = extractAvailableCuisines(<Restaurant>[]);
    expect(available, isEmpty);
  });

  test('filterRestaurantsByCuisine empty selection returns all', () {
    final filtered = filterRestaurantsByCuisine(restaurants, []);
    expect(filtered.length, equals(restaurants.length));
  });

  test(
    'filterRestaurantsByCuisine supports multiple selections and exact matching',
    () {
      final filtered = filterRestaurantsByCuisine(restaurants, [
        'Mexican',
        '  Thai ',
      ]);
      final names = filtered.map((r) => r.name).toList();
      expect(names, containsAll(['R2', 'R6', 'R4']));
    },
  );

  test(
    'filterRestaurantsByCuisine is case-sensitive (exact match required)',
    () {
      final filtered = filterRestaurantsByCuisine(restaurants, ['Italian']);
      expect(filtered.length, equals(1));
      expect(filtered.first.name, 'R1');

      final lower = filterRestaurantsByCuisine(restaurants, ['italian']);
      expect(lower.length, equals(1));
      expect(lower.first.name, 'R3');
    },
  );

  test(
    'filterRestaurantsByCuisine unknown cuisine returns empty and available becomes empty after filtering',
    () {
      final filtered = filterRestaurantsByCuisine(restaurants, ['Thai']);
      expect(filtered, isEmpty);

      final availableAfter = extractAvailableCuisines(filtered);
      expect(availableAfter, isEmpty);
    },
  );

  test(
    'simulate HomeScreen cuisine flow: selecting cuisines updates restaurant list and available cuisines',
    () {
      // initial state
      var unfiltered = restaurants;
      var restaurantList = unfiltered;
      var available = extractAvailableCuisines(restaurantList);
      expect(available.contains('Mexican'), isTrue);

      // user selects Mexican
      final selected = ['Mexican'];
      restaurantList = filterRestaurantsByCuisine(unfiltered, selected);
      final newAvailable = extractAvailableCuisines(restaurantList);

      // newAvailable should only contain cuisines present in restaurantList
      final expectedSet = restaurantList.map((r) => r.cuisine).toSet();
      expect(newAvailable.toSet(), equals(expectedSet));
    },
  );

  test(
    'filterRestaurantsByCuisine supports empty-string cuisine filtering',
    () {
      final filtered = filterRestaurantsByCuisine(restaurants, ['']);
      expect(filtered.map((r) => r.name), contains('R5'));
    },
  );
}
