import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:nomnom_safe/services/address_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AddressService service;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    service = AddressService(fakeFirestore);

    await fakeFirestore.collection('addresses').doc('addr1').set({
      'id': 'addr1',
      'street': '123 Test St',
      'city': 'Test City',
      'state': 'TS',
      'zipCode': '12345',
    });
  });

  test('getRestaurantAddress returns full address string', () async {
    final full = await service.getRestaurantAddress('addr1');
    expect(full, isNotNull);
    expect(full, contains('123 Test St'));
    expect(full, contains('Test City'));
  });

  test('getRestaurantAddress returns Unknown for missing/empty', () async {
    final missing = await service.getRestaurantAddress('nonexistent');
    expect(missing, 'Unknown');

    final empty = await service.getRestaurantAddress('');
    expect(empty, 'Unknown');
  });
}
