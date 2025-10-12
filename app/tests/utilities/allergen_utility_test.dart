import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/utils/allergen_utility.dart';
import 'package:nomnom_safe/models/allergen.dart';

void main() {
  test('extractAllergenLabels returns labels', () {
    final list = [
      Allergen(id: 'a1', label: 'P'),
      Allergen(id: 'a2', label: 'D'),
    ];
    final labels = extractAllergenLabels(list);
    expect(labels, ['P', 'D']);
  });

  test('formatAllergenList various counts', () {
    expect(formatAllergenList([], 'or'), '(no allergens selected)');
    expect(formatAllergenList(['Peanuts'], 'or'), 'peanuts');
    expect(formatAllergenList(['Peanuts', 'Dairy'], 'or'), 'peanuts or dairy');
    expect(
      formatAllergenList(['A', 'B', 'C'], 'or'),
      'A, B, or C'.toLowerCase(),
    );
  });
}
