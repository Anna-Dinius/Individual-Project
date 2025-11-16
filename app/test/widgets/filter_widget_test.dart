import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/filter_modal.dart';

void main() {
  testWidgets(
    'Filter dialog shows options, allows selection and Apply returns selections',
    (tester) async {
      List<String>? result;
      final options = ['Italian', 'Mexican', 'Thai'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(
              buttonLabel: 'Cuisines',
              title: 'Filter by Cuisine',
              options: options,
              selectedOptions: ['Italian'],
              onChanged: (selected) {
                result = selected;
              },
            ),
          ),
        ),
      );

      // Open the dialog by tapping the visible button label
      await tester.tap(find.text('Cuisines'));
      await tester.pumpAndSettle();

      // Dialog should show all options
      for (final opt in options) {
        expect(find.text(opt), findsOneWidget);
      }

      // Toggle 'Mexican'
      await tester.tap(find.text('Mexican'));
      await tester.pumpAndSettle();

      // Apply selection
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result, containsAll(['Italian', 'Mexican']));
    },
  );

  testWidgets('Filter dialog Clear Selection clears temporary selections', (
    tester,
  ) async {
    List<String>? result;
    final options = ['A', 'B'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterModal(
            buttonLabel: 'Test',
            title: 'Test',
            options: options,
            selectedOptions: [],
            onChanged: (selected) {
              result = selected;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cuisines'));
    await tester.pumpAndSettle();

    // Select both options
    await tester.tap(find.text('A'));
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();

    // Clear Selection button should appear; tap it
    expect(find.text('Clear Selection'), findsOneWidget);
    await tester.tap(find.text('Clear Selection'));
    await tester.pumpAndSettle();

    // Now Apply should return empty list
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result, isEmpty);
  });
}
