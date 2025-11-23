import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/allergen.dart';
import 'package:nomnom_safe/widgets/allergen_chip.dart';

/// Widget to display a list of allergen filter chips and a Clear button
class AllergenFilter extends StatelessWidget {
  final List<Allergen> availableAllergens; // all allergen options
  final List<Allergen> selectedAllergens; // currently selected allergens
  final void Function(Allergen) onToggle; // callback for toggling selection
  final VoidCallback? onClear; // callback for clearing all selections
  final bool showClearButton; // whether to show the Clear button

  const AllergenFilter({
    super.key,
    required this.availableAllergens,
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
        // Instructional text
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
        // Filter chips for each allergen
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: availableAllergens.map((allergen) {
            final isSelected = selectedAllergens.any(
              (selectedAllergen) => selectedAllergen.id == allergen.id,
            );
            return AllergenChip(
              allergen: allergen,
              isSelected: isSelected,
              onToggle: onToggle,
            );
          }).toList(),
        ),
        // Clear Filters button
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
