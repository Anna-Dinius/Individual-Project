import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/allergen.dart';

import 'fake_firestore.dart';

void main() {
  group('AllergenService', () {
    test(
      'idsToLabels and labelsToIds maps convert correctly and handle unknowns',
      () async {
        final fakeAllergens = [
          FakeDocument('a1', {'id': 'a1', 'label': 'Peanuts'}),
          FakeDocument('a2', {'id': 'a2', 'label': 'Dairy'}),
        ];
        final fs = FakeFirestore({'allergens': fakeAllergens});
        final service = AllergenService(fs);

        final all = await service.getAllergens();
        expect(all, isA<List<Allergen>>());
        expect(all.map((a) => a.id), containsAll(['a1', 'a2']));

        final labels = await service.idsToLabels(['a1', 'x']);
        expect(labels, containsAll(['Peanuts', 'x']));

        final ids = await service.labelsToIds(['Dairy', 'Unknown']);
        expect(ids, containsAll(['a2', 'Unknown']));
      },
    );

    test('getAllergens returns empty list when no collection', () async {
      final fs = FakeFirestore({});
      final service = AllergenService(fs);
      final all = await service.getAllergens();
      expect(all, isEmpty);
    });
  });
}
