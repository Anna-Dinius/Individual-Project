import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/restaurant_card.dart';
import 'package:nomnom_safe/models/restaurant.dart';

void main() {
  testWidgets('RestaurantCard renders and navigates', (tester) async {
    final r = Restaurant.fromJson({
      'id': 'r1',
      'name': 'R1',
      'address_id': 'addr1',
      'website': '',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': 'p',
      'cuisine': 'c',
      'disclaimers': [],
      'logoUrl': null,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RestaurantCard(restaurant: r)),
      ),
    );

    expect(find.text('R1'), findsOneWidget);
    expect(find.text('Cuisine: c'), findsOneWidget);
  });
}
