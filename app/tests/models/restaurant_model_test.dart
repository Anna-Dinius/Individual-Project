import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/restaurant.dart';

void main() {
  test('Restaurant.fromJson and helpers', () {
    final data = {
      'id': 'r1',
      'name': 'R1',
      'address_id': 'addr1',
      'website': 'http://t',
      'hours': ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
      'phone': 'p',
      'cuisine': 'c',
      'disclaimers': [],
      'logoUrl': null,
    };
    final r = Restaurant.fromJson(data);
    expect(r.id, 'r1');
    expect(r.hasWebsite, true);
    expect(r.todayHours, isNotNull);
  });
}
