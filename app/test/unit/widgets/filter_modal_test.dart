import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/filter_modal.dart';

void main() {
  testWidgets('FilterModal opens dialog and applies selection', (tester) async {
    List<String>? applied;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterModal(
            buttonLabel: 'Filter',
            title: 'Choose',
            options: ['one', 'two'],
            selectedOptions: [],
            onChanged: (sel) => applied = sel,
          ),
        ),
      ),
    );

    // Tap button to open dialog
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    // Dialog should be visible with 'Apply' button
    expect(find.text('Apply'), findsOneWidget);

    // Tap Apply without selecting anything
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied, isNotNull);
    expect(applied, isEmpty);
  });
}
