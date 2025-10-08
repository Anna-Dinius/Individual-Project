import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/allergen.dart';

class AllergenService {
  final FirebaseFirestore _firestore;
  Map<String, String>? _cachedLabelToIdMap;

  AllergenService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, String>> getAllergenLabelToIdMap() async {
    if (_cachedLabelToIdMap != null) return _cachedLabelToIdMap!;

    final snapshot = await _firestore.collection('allergens').get();
    _cachedLabelToIdMap = {for (var doc in snapshot.docs) doc['label']: doc.id};

    return _cachedLabelToIdMap!;
  }

  Future<List<String>> getAllergenLabels() async {
    final snapshot = await _firestore.collection('allergens').get();

    return snapshot.docs.map((doc) => doc['label'] as String).toList();
  }

  Future<List<String>> getAllergenIds() async {
    final snapshot = await _firestore.collection('allergens').get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<Allergen>> getAllergens() async {
    final snapshot = await _firestore.collection('allergens').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Allergen.fromJson(doc.id, data);
    }).toList();
  }

  Future<Map<String, String>> getAllergenIdToLabelMap() async {
    final snapshot = await _firestore.collection('allergens').get();

    return {
      for (var doc in snapshot.docs) doc.id: doc.data()?['label'] ?? 'Unknown',
    };
  }
}
