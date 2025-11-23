import 'package:nomnom_safe/models/allergen.dart';

/// Extracts allergen labels from a list of Allergen objects
List<String> extractAllergenLabels(List<Allergen> allergens) {
  return allergens.map((allergen) => allergen.label).toList();
}

/// Formats a list of allergen labels into a human-readable string
String formatAllergenList(List<String> allergens, String conjunction) {
  if (allergens.isEmpty) return '(no allergens selected)';
  if (allergens.length == 1) return allergens.first.toLowerCase();
  if (allergens.length == 2) {
    final first = allergens[0].toLowerCase();
    final second = allergens[1].toLowerCase();
    return '$first $conjunction $second';
  }
  final allButLast = allergens.sublist(0, allergens.length - 1).join(', ');
  final last = allergens.last;

  return ('$allButLast, $conjunction $last').toLowerCase();
}
