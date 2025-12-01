import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/screens/restaurant_screen.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/services/address_service.dart';

class FakeAddressService implements AddressService {
  @override
  Future<String?> getRestaurantAddress(String addressId) async => '123 Test St';
}

Restaurant _makeRestaurant() => Restaurant(
  id: 'r1',
  name: 'Testaurant',
  addressId: 'addr1',
  website: '',
  hours: List.generate(7, (i) => 'Hours $i'),
  phone: '555-0000',
  cuisine: 'Test',
  disclaimers: [],
  logoUrl: null,
);

void main() {
  testWidgets('RestaurantScreen shows name and loading address', (
    tester,
  ) async {
    final r = _makeRestaurant();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantScreen(
            restaurant: r,
            addressService: FakeAddressService(),
          ),
        ),
      ),
    );

    expect(find.text('Testaurant'), findsOneWidget);
    // Address fetch runs async; initial build should display Loading...
    expect(find.textContaining('Address:'), findsOneWidget);
    expect(find.textContaining('Loading'), findsOneWidget);
  });
}
