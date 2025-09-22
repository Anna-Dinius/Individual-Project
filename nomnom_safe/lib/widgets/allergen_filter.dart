import 'package:flutter/material.dart';

class AllergenFilter extends StatefulWidget {
  final List<String> allergens;
  final Function(List<String>) onSelectionChanged;

  const AllergenFilter({
    super.key,
    required this.allergens,
    required this.onSelectionChanged,
  });

  @override
  State<AllergenFilter> createState() => _AllergenFilterState();
}

class _AllergenFilterState extends State<AllergenFilter> {
  final List<String> _selectedAllergens = [];

  void _toggleSelection(String allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
      }
      widget.onSelectionChanged(_selectedAllergens);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.allergens.map((allergen) {
        final isSelected = _selectedAllergens.contains(allergen);
        return FilterChip(
          label: Text(allergen),
          selected: isSelected,
          onSelected: (_) => _toggleSelection(allergen),
          selectedColor: Colors.green[300],
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }
}
