import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/widgets/multi_select_checkbox_list.dart';

void main() {
  testWidgets('MultiSelectCheckboxList renders options and calls onChanged', (
    tester,
  ) async {
    final options = ['A', 'B', 'C'];
    final selected = <String>{'B'};
    String? lastChangedLabel;
    bool? lastChecked;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiSelectCheckboxList(
            options: options,
            selected: selected,
            onChanged: (label, checked) {
              lastChangedLabel = label;
              lastChecked = checked;
            },
          ),
        ),
      ),
    );

    // Should render three checkbox tiles
    expect(find.byType(CheckboxListTile), findsNWidgets(3));

    // Tap first checkbox
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(lastChangedLabel, 'A');
    expect(lastChecked, isTrue);
  });
}
