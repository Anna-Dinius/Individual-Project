import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/address_service.dart';

import 'fake_firestore.dart';

void main() {
  group('AddressService', () {
    test('returns Unknown for empty id', () async {
      final fs = FakeFirestore({});
      final service = AddressService(fs);
      final addr = await service.getRestaurantAddress('');
      expect(addr, 'Unknown');
    });

    test('returns Unknown when doc missing', () async {
      final fs = FakeFirestore({'addresses': []});
      final service = AddressService(fs);
      final addr = await service.getRestaurantAddress('r1');
      expect(addr, 'Unknown');
    });
  });
}
