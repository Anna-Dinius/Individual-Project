import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/utils/allergen_utils.dart';
import 'package:nomnom_safe/models/allergen.dart';

void main() {
  group('Allergen utils', () {
    test('extractAllergenLabels returns labels in same order', () {
      final allergens = [
        Allergen(id: 'a', label: 'Peanuts'),
        Allergen(id: 'b', label: 'Milk'),
      ];

      final labels = extractAllergenLabels(allergens);
      expect(labels, ['Peanuts', 'Milk']);
    });

    test('formatAllergenList handles empty, single, two and many', () {
      expect(formatAllergenList([], 'and'), '(no allergens selected)');
      expect(formatAllergenList(['Peanuts'], 'and'), 'peanuts');
      expect(
        formatAllergenList(['Peanuts', 'Milk'], 'and'),
        'peanuts and milk',
      );
      expect(
        formatAllergenList(['Peanuts', 'Milk', 'Shellfish'], 'or'),
        'peanuts, milk, or shellfish',
      );
    });

    test('formatAllergenList lowercases properly and handles punctuation', () {
      final list = ['PEANUTS', 'Milk', 'Shrimp'];
      final out = formatAllergenList(list, 'and');
      expect(out, 'peanuts, milk, and shrimp');
    });
  });
}
