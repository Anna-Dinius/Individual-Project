import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/models/restaurant.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RestaurantService service;

  final mockRestaurants = [
    {
      'id': 'r1',
      'name': 'Test 1',
      'address_id': 'addr1',
      'website': '',
      'hours': ['9-5', '9-5', '9-5', '9-5', '9-5', '10-4', '10-4'],
      'phone': '111',
      'cuisine': 'A',
      'disclaimers': [],
      'logoUrl': '',
    },
    {
      'id': 'r2',
      'name': 'Test 2',
      'address_id': 'addr2',
      'website': '',
      'hours': ['9-5', '9-5', '9-5', '9-5', '9-5', '10-4', '10-4'],
      'phone': '222',
      'cuisine': 'B',
      'disclaimers': [],
      'logoUrl': '',
    },
  ];

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    service = RestaurantService(fakeFirestore);

    // menus
    await fakeFirestore.collection('menus').doc('m1').set({
      'id': 'm1',
      'restaurant_id': 'r1',
    });
    await fakeFirestore.collection('menus').doc('m2').set({
      'id': 'm2',
      'restaurant_id': 'r2',
    });

    // menu items: r1 has items with allergen a1, r2 has allergen-free item
    await fakeFirestore.collection('menu_items').add({
      'allergens': ['a1'],
      'menu_id': 'm1',
    });
    await fakeFirestore.collection('menu_items').add({
      'allergens': ['a1'],
      'menu_id': 'm1',
    });
    await fakeFirestore.collection('menu_items').add({
      'allergens': [],
      'menu_id': 'm2',
    });
  });

  test('filterRestaurantsFromList returns all if no allergens', () async {
    final restaurants = mockRestaurants
        .map((r) => Restaurant.fromJson(Map<String, dynamic>.from(r)))
        .toList();
    final filtered = await service.filterRestaurantsFromList(restaurants, []);
    expect(filtered.length, equals(restaurants.length));
  });

  test(
    'filterRestaurantsFromList filters out restaurants with all items unsafe',
    () async {
      final restaurants = mockRestaurants
          .map((r) => Restaurant.fromJson(Map<String, dynamic>.from(r)))
          .toList();
      final filtered = await service.filterRestaurantsFromList(restaurants, [
        'a1',
      ]);
      // r1 should be filtered out because all its items contain a1; r2 remains
      expect(filtered.length, equals(1));
    },
  );
}
