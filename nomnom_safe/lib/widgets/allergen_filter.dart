import 'package:flutter/material.dart';

class AllergenFilter extends StatelessWidget {
  final List<String> allergens;
  final List<String> selectedAllergens;
  final void Function(String) onToggle;
  final VoidCallback? onClear;
  final bool showClearButton;

  const AllergenFilter({
    super.key,
    required this.allergens,
    required this.selectedAllergens,
    required this.onToggle,
    this.onClear,
    required this.showClearButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: "Select the allergens you want to "),
                TextSpan(
                  text: "avoid",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ":"),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ...allergens.map((allergen) {
              final isSelected = selectedAllergens.contains(allergen);
              return FilterChip(
                label: Text(allergen),
                selected: isSelected,
                onSelected: (_) => onToggle(allergen),
                selectedColor: Colors.green[300],
                checkmarkColor: Colors.white,
              );
            }),
          ],
        ),
        Visibility(
          visible: showClearButton && onClear != null,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ),
        ),
      ],
    );
  }
}
