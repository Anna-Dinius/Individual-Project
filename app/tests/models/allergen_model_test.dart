import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/allergen.dart';

void main() {
  test('Allergen.fromJson', () {
    final json = {'label': 'Peanuts'};
    final a = Allergen.fromJson('a1', json);
    expect(a.id, 'a1');
    expect(a.label, 'Peanuts');
  });
}
