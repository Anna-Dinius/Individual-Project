import 'package:cloud_firestore/cloud_firestore.dart' as fb;

/// Lightweight Firestore adapter interfaces used by AuthService to allow
/// tests to inject a test double without pulling in the real SDK at test
/// time.

abstract class DocumentAdapter {
  String get id;
  Future<Map<String, dynamic>?> get();
  Future<void> set(Map<String, dynamic> data);
  Future<void> update(Map<String, dynamic> data);
  Future<void> delete();
}

abstract class CollectionAdapter {
  DocumentAdapter doc(String id);
}

abstract class FirestoreAdapter {
  CollectionAdapter collection(String name);
}

// Production implementations wrapping cloud_firestore types
class FirebaseDocumentAdapter implements DocumentAdapter {
  final fb.DocumentReference _ref;
  FirebaseDocumentAdapter(this._ref);

  @override
  String get id => _ref.id;

  @override
  Future<Map<String, dynamic>?> get() async {
    final snap = await _ref.get();
    return snap.exists ? snap.data() as Map<String, dynamic> : null;
  }

  @override
  Future<void> set(Map<String, dynamic> data) => _ref.set(data);

  @override
  Future<void> update(Map<String, dynamic> data) => _ref.update(data);

  @override
  Future<void> delete() => _ref.delete();
}

class FirebaseCollectionAdapter implements CollectionAdapter {
  final fb.CollectionReference _col;
  FirebaseCollectionAdapter(this._col);

  @override
  DocumentAdapter doc(String id) => FirebaseDocumentAdapter(_col.doc(id));
}

class FirebaseFirestoreAdapter implements FirestoreAdapter {
  final fb.FirebaseFirestore _fs;
  FirebaseFirestoreAdapter([fb.FirebaseFirestore? fs])
    : _fs = fs ?? fb.FirebaseFirestore.instance;

  @override
  CollectionAdapter collection(String name) =>
      FirebaseCollectionAdapter(_fs.collection(name));
}
