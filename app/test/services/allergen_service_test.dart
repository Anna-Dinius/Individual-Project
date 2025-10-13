import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/allergen.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AllergenService service;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    service = AllergenService(fakeFirestore);

    await fakeFirestore.collection('allergens').doc('a1').set({
      'label': 'Peanuts',
    });
    await fakeFirestore.collection('allergens').doc('a2').set({
      'label': 'Dairy',
    });
    await fakeFirestore.collection('allergens').doc('a3').set({
      'label': 'Gluten',
    });
  });

  test('getAllergens returns Allergen objects', () async {
    final allergens = await service.getAllergens();
    expect(allergens.length, 3);
    expect(
      allergens.map((a) => a.label),
      containsAll(['Peanuts', 'Dairy', 'Gluten']),
    );
    expect(allergens.first, isA<Allergen>());
  });

  test('getAllergenLabels and ids and maps', () async {
    final labels = await service.getAllergenLabels();
    expect(labels, containsAll(['Peanuts', 'Dairy', 'Gluten']));

    final ids = await service.getAllergenIds();
    expect(ids, containsAll(['a1', 'a2', 'a3']));

    final idToLabel = await service.getAllergenIdToLabelMap();
    expect(idToLabel['a1'], 'Peanuts');

    final labelToId = await service.getAllergenLabelToIdMap();
    expect(labelToId['Peanuts'], 'a1');
  });

  test(
    'getAllergens caching behavior (reads from cache on subsequent calls)',
    () async {
      final first = await service.getAllergens();
      expect(first.length, 3);

      // Add another allergen doc to the fake firestore after first fetch
      await fakeFirestore.collection('allergens').doc('a4').set({
        'label': 'Soy',
      });

      // Call getAllergens again - because service is designed to cache, it should still return 3
      final second = await service.getAllergens();
      expect(second.length, 3);
      // Clear cache and verify fetch sees new doc (simulate invalidation)
      service = AllergenService(fakeFirestore);
      final third = await service.getAllergens();
      expect(third.length, 4);
    },
  );
}
