import 'package:cloud_firestore/cloud_firestore.dart';

class Allergen {
  final String id;
  final String label;

  Allergen({required this.id, required this.label});

  factory Allergen.fromJson(String id, Map<String, dynamic> json) {
    return Allergen(id: id, label: json['label']);
  }

  // TODO: move to service
  Future<List<String>> getAllergenIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allergens')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // TODO: move to service
  Future<List<Allergen>> getAllergens() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allergens')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Allergen.fromJson(doc.id, data);
    }).toList();
  }
}
