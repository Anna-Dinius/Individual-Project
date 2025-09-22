import 'package:cloud_firestore/cloud_firestore.dart';

class AllergenService {
  Future<List<String>> getAllergenLabels() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allergens')
        .get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['label'] ?? 'Unknown';
        })
        .toList()
        .cast<String>();
  }
}
