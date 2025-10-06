String formatAllergenList(List<String> allergens, String conjunction) {
  if (allergens.isEmpty) return 'None';
  if (allergens.length == 1) return allergens.first.toLowerCase();
  final allButLast = allergens.sublist(0, allergens.length - 1).join(', ');
  final last = allergens.last;

  return ('$allButLast, $conjunction $last').toLowerCase();
}
