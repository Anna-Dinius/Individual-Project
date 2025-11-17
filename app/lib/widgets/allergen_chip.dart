import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/allergen.dart';

/* Widget to display an allergen as a selectable chip */
class AllergenChip extends StatelessWidget {
  final Allergen allergen;
  final bool isSelected;
  final void Function(Allergen) onToggle;

  const AllergenChip({
    super.key,
    required this.allergen,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        allergen.label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
      selected: isSelected,
      onSelected: (_) => onToggle(allergen),
    );
  }
}
