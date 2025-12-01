import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/address.dart';

void main() {
  test('Address fromJson and full', () {
    final data = {
      'id': 'a1',
      'street': '1 St',
      'city': 'C',
      'state': 'S',
      'zipCode': '000',
    };
    final addr = Address.fromJson(data);
    expect(addr.id, 'a1');
    expect(addr.full, contains('1 St'));
  });
}
