import 'package:flutter/material.dart';

class MultiSelectCheckboxList extends StatelessWidget {
  final List<String> options; // checkbox labels
  final Set<String> selected; // selected labels
  final void Function(String label, bool checked) onChanged;

  const MultiSelectCheckboxList({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((label) {
        final isSelected = selected.contains(label);
        return CheckboxListTile(
          title: Text(label),
          value: isSelected,
          onChanged: (checked) => onChanged(label, checked ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }
}
