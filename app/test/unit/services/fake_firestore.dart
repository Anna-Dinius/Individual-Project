class FakeDocument {
  final String id;
  final Map<String, dynamic>? dataMap;
  FakeDocument(this.id, this.dataMap);
}

class FakeDocumentSnapshot {
  final FakeDocument _doc;
  FakeDocumentSnapshot(this._doc);
  Map<String, dynamic>? data() => _doc.dataMap;
  String get id => _doc.id;
  bool get exists => _doc.dataMap != null;
}

class FakeQuerySnapshot {
  final List<FakeDocumentSnapshot> docs;
  FakeQuerySnapshot(this.docs);
}

class FakeQuery {
  final List<FakeDocument> _allDocs;
  final List<FakeDocument> _currentDocs;
  FakeQuery(List<FakeDocument> docs)
    : _allDocs = docs,
      _currentDocs = List.from(docs);
  FakeQuery._(this._allDocs, this._currentDocs);

  FakeQuery where(String field, {required Object? isEqualTo}) {
    final filtered = _currentDocs
        .where((d) => (d.dataMap != null && d.dataMap![field] == isEqualTo))
        .toList();
    return FakeQuery._(_allDocs, filtered);
  }

  FakeQuery limit(int n) {
    return FakeQuery._(_allDocs, _currentDocs.take(n).toList());
  }

  Future<FakeQuerySnapshot> get() async {
    return FakeQuerySnapshot(
      _currentDocs.map((d) => FakeDocumentSnapshot(d)).toList(),
    );
  }
}

class FakeDocumentRef {
  final String id;
  final List<FakeDocument> _docs;
  FakeDocumentRef(this.id, this._docs);

  Future<FakeDocumentSnapshot> get() async {
    final found = _docs.firstWhere(
      (d) => d.id == id,
      orElse: () => FakeDocument(id, null),
    );
    return FakeDocumentSnapshot(found);
  }

  Future<void> set(Map<String, dynamic> data) async {
    final idx = _docs.indexWhere((d) => d.id == id);
    final doc = FakeDocument(id, Map<String, dynamic>.from(data));
    if (idx >= 0) {
      _docs[idx] = doc;
    } else {
      _docs.add(doc);
    }
  }

  Future<void> update(Map<String, dynamic> data) async {
    final idx = _docs.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      final existing = _docs[idx].dataMap ?? {};
      final merged = Map<String, dynamic>.from(existing)..addAll(data);
      _docs[idx] = FakeDocument(id, merged);
    } else {
      // If not found, create new
      _docs.add(FakeDocument(id, Map<String, dynamic>.from(data)));
    }
  }

  Future<void> delete() async {
    _docs.removeWhere((d) => d.id == id);
  }
}

class FakeCollection {
  final List<FakeDocument> _docs;
  FakeCollection(this._docs);

  FakeQuery where(String field, {required Object? isEqualTo}) =>
      FakeQuery(_docs).where(field, isEqualTo: isEqualTo);
  FakeQuery limit(int n) => FakeQuery(_docs).limit(n);
  Future<FakeQuerySnapshot> get() async =>
      FakeQuerySnapshot(_docs.map((d) => FakeDocumentSnapshot(d)).toList());
  FakeDocumentRef doc(String id) => FakeDocumentRef(id, _docs);
}

class FakeFirestore {
  final Map<String, List<FakeDocument>> collections;
  FakeFirestore(this.collections);

  FakeCollection collection(String name) =>
      FakeCollection(collections[name] ?? []);
}
