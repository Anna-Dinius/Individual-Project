import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/services/address_service.dart';

// Mock data for testing
final mockAllergens = [
  {'id': 'a1', 'label': 'Peanuts'},
  {'id': 'a2', 'label': 'Dairy'},
  {'id': 'a3', 'label': 'Gluten'},
];

final mockRestaurants = [
  {
    'id': 'r1',
    'name': 'Test Restaurant 1',
    'address_id': 'addr1',
    'website': 'http://test1.com',
    'hours': ['9-5', '9-5', '9-5', '9-5', '9-5', '10-4', '10-4'],
    'phone': '555-0001',
    'cuisine': 'Test Cuisine',
    'disclaimers': ['Test disclaimer'],
    'logoUrl': 'http://test1.com/logo.png',
  },
  {
    'id': 'r2',
    'name': 'Test Restaurant 2',
    'address_id': 'addr2',
    'website': 'http://test2.com',
    'hours': ['9-5', '9-5', '9-5', '9-5', '9-5', '10-4', '10-4'],
    'phone': '555-0002',
    'cuisine': 'Test Cuisine 2',
    'disclaimers': ['Test disclaimer 2'],
    'logoUrl': 'http://test2.com/logo.png',
  },
];

final mockAddresses = [
  {
    'id': 'addr1',
    'street': '123 Test St',
    'city': 'Test City',
    'state': 'TS',
    'zipCode': '12345',
  },
  {
    'id': 'addr2',
    'street': '456 Mock Ave',
    'city': 'Mock City',
    'state': 'MC',
    'zipCode': '67890',
  },
];

final mockMenus = [
  {'id': 'm1', 'restaurant_id': 'r1'},
  {'id': 'm2', 'restaurant_id': 'r2'},
];

final mockMenuItems = [
  {
    'id': 'mi1',
    'name': 'Test Item 1',
    'description': 'Test Description 1',
    'allergens': <String>['a1', 'a2'],
    'menu_id': 'm1',
  },
  {
    'id': 'mi2',
    'name': 'Test Item 2',
    'description': 'Test Description 2',
    'allergens': <String>['a1'],
    'menu_id': 'm1',
  },
  {
    'id': 'mi3',
    'name': 'Test Item 3',
    'description': 'Test Description 3',
    'allergens': <String>[],
    'menu_id': 'm2',
  },
];

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AllergenService allergenService;
  late RestaurantService restaurantService;
  late AddressService addressService;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    allergenService = AllergenService(fakeFirestore);
    restaurantService = RestaurantService(fakeFirestore);
    addressService = AddressService(fakeFirestore);

    // Populate fake Firestore with mock data
    for (final allergen in mockAllergens) {
      await fakeFirestore
          .collection('allergens')
          .doc(allergen['id'] as String)
          .set({'label': allergen['label']});
    }

    for (final restaurant in mockRestaurants) {
      await fakeFirestore
          .collection('restaurants')
          .doc(restaurant['id'] as String)
          .set(Map<String, dynamic>.from(restaurant));
    }

    for (final address in mockAddresses) {
      await fakeFirestore
          .collection('addresses')
          .doc(address['id'] as String)
          .set(Map<String, dynamic>.from(address));
    }

    for (final menu in mockMenus) {
      await fakeFirestore
          .collection('menus')
          .doc(menu['id'] as String)
          .set(Map<String, dynamic>.from(menu));
    }

    for (final menuItem in mockMenuItems) {
      await fakeFirestore
          .collection('menu_items')
          .add(Map<String, dynamic>.from(menuItem));
    }
  });

  group('AllergenService Tests', () {
    test('getAllergenLabels returns correct labels', () async {
      final labels = await allergenService.getAllergenLabels();
      expect(labels, containsAll(['Peanuts', 'Dairy', 'Gluten']));
      expect(labels.length, equals(3));
    });

    test('getAllergens returns all allergens with correct data', () async {
      final allergens = await allergenService.getAllergens();
      expect(allergens.length, equals(3));
      expect(
        allergens.map((a) => a.label),
        containsAll(['Peanuts', 'Dairy', 'Gluten']),
      );
    });

    test('getAllergenIds returns correct IDs', () async {
      final ids = await allergenService.getAllergenIds();
      expect(ids, containsAll(['a1', 'a2', 'a3']));
      expect(ids.length, equals(3));
    });

    test('getAllergenIdToLabelMap returns correct mapping', () async {
      final map = await allergenService.getAllergenIdToLabelMap();
      expect(map, equals({'a1': 'Peanuts', 'a2': 'Dairy', 'a3': 'Gluten'}));
    });
  });

  group('RestaurantService Tests', () {
    test(
      'getFilteredRestaurants returns all restaurants when no allergens selected',
      () async {
        final allRestaurants = mockRestaurants
            .map((r) => Restaurant.fromJson(r))
            .toList();

        final filtered = await restaurantService.getFilteredRestaurants(
          [],
          allRestaurants,
        );
        expect(filtered.length, equals(allRestaurants.length));
      },
    );

    test(
      'getFilteredRestaurants filters correctly with selected allergens',
      () async {
        final allRestaurants = mockRestaurants
            .map((r) => Restaurant.fromJson(Map<String, dynamic>.from(r)))
            .toList();

        // Test with peanut allergy (a1)
        final filtered = await restaurantService.getFilteredRestaurants([
          'a1',
        ], allRestaurants);

        // Only Restaurant 2 should be safe (r1 has peanuts in item1, r2 has no peanuts)
        expect(filtered.length, equals(1));
        expect(filtered.first.id, equals('r2'));
      },
    );
  });

  group('AddressService Tests', () {
    test(
      'getRestaurantAddress returns correct address for restaurant',
      () async {
        final restaurant = Restaurant.fromJson(mockRestaurants[0]);
        final address = await addressService.getRestaurantAddress(restaurant);

        expect(address, isNotNull);
        expect(address!.street, equals('123 Test St'));
        expect(address.city, equals('Test City'));
        expect(address.state, equals('TS'));
        expect(address.zipCode, equals('12345'));
      },
    );

    test(
      'getRestaurantAddress returns null for non-existent address',
      () async {
        final restaurant = Restaurant.fromJson({
          ...mockRestaurants[0],
          'address_id': 'non-existent',
        });

        final address = await addressService.getRestaurantAddress(restaurant);
        expect(address, isNull);
      },
    );
  });
}
