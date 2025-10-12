import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/menu_item.dart';

void main() {
  test('MenuItem.fromJson and toJson', () {
    final data = {
      'id': 'mi1',
      'name': 'Item 1',
      'description': 'Desc',
      'hours': <String>[],
      'menu_id': 'm1',
    };

    final item = MenuItem.fromJson(data);
    expect(item.id, 'mi1');
    expect(item.menuId, 'm1');
    final json = item.toJson();
    expect(json['menu_id'], 'm1');
    expect(json['name'], 'Item 1');
  });
}
