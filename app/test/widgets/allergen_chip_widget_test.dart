import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/allergen_chip.dart';
import 'package:nomnom_safe/models/allergen.dart';

void main() {
  testWidgets('AllergenChip displays label and toggles', (tester) async {
    final a = Allergen(id: 'a1', label: 'P');
    bool toggled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AllergenChip(
            allergen: a,
            isSelected: false,
            onToggle: (_) {
              toggled = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('P'), findsOneWidget);
    await tester.tap(find.text('P'));
    expect(toggled, true);
  });
}
