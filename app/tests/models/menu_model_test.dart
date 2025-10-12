import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/menu.dart';

void main() {
  test('Menu.fromJson and toJson', () {
    final data = {'id': 'm1', 'restaurant_id': 'r1'};
    final menu = Menu.fromJson(data);
    expect(menu.id, 'm1');
    expect(menu.restaurantId, 'r1');
    expect(menu.toJson()['restaurant_id'], 'r1');
  });
}
