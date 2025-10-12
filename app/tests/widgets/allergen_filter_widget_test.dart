import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_safe/widgets/allergen_filter.dart';
import 'package:nomnom_safe/models/allergen.dart';

void main() {
  testWidgets('AllergenFilter shows chips and clear button', (tester) async {
    final allergens = [
      Allergen(id: 'a1', label: 'A'),
      Allergen(id: 'a2', label: 'B'),
      Allergen(id: 'a3', label: 'C'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AllergenFilter(
            availableAllergens: allergens,
            selectedAllergens: [allergens[0]],
            onToggle: (_) {},
            onClear: () {},
            showClearButton: true,
          ),
        ),
      ),
    );

    // Instruction contains the word 'avoid'
    expect(find.textContaining('avoid'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    // AllergenChip should be rendered for each allergen
    expect(find.byType(AllergenFilter), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(3));
    expect(find.text('Clear Filters'), findsOneWidget);
  });
}
