import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/allergen.dart';

/* Service class to handle allergen-related Firestore operations */
class AllergenService {
  final FirebaseFirestore _firestore;
  List<Allergen>? _cachedAllergens;

  AllergenService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /* Get list of Allergen objects */
  Future<List<Allergen>> getAllergens() async {
    if (_cachedAllergens != null) return _cachedAllergens!;

    final snapshot = await _firestore.collection('allergens').get();

    final allergens = snapshot.docs.map((doc) {
      final data = doc.data();
      return Allergen.fromJson(doc.id, data);
    }).toList();

    _cachedAllergens = allergens;
    return allergens;
  }

  /* Get map of allergen ids to allergen labels */
  Future<Map<String, String>> getAllergenIdToLabelMap() async {
    final allergens = await getAllergens();

    return Map.fromEntries(
      allergens.map((allergen) => MapEntry(allergen.id, allergen.label)),
    );
  }

  /* Get map of allergen labels to allergen ids */
  Future<Map<String, String>> getAllergenLabelToIdMap() async {
    final allergens = await getAllergens();

    return Map.fromEntries(
      allergens.map((allergen) => MapEntry(allergen.label, allergen.id)),
    );
  }

  /* Get list of allergen labels */
  Future<List<String>> getAllergenLabels() async {
    final allergens = await getAllergens();

    return allergens.map((allergen) => allergen.label).toList();
  }

  /* Get list of allergen ids */
  Future<List<String>> getAllergenIds() async {
    final allergens = await getAllergens();

    return allergens.map((allergen) => allergen.id).toList();
  }
}
