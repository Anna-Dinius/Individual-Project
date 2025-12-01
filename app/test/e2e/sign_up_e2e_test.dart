import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/auth_service.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';

class _FakeUserAdapter implements UserAdapter {
  final String uid;
  final String? email;
  _FakeUserAdapter(this.uid, {this.email});
  @override
  Future<void> delete() async {}
  @override
  Future<void> reauthenticateWithCredential(dynamic credential) async {}
  @override
  Future<void> updatePassword(String password) async {}
  @override
  Future<void> verifyBeforeUpdateEmail(String email) async {}
}

class _FakeAuthAdapter implements AuthAdapter {
  _FakeUserAdapter? _user;
  @override
  UserAdapter? get currentUser => _user;

  @override
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('uid_new', email: email);
    return {'user': _user};
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('uid_new', email: email);
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

class _FakeDocumentAdapter implements DocumentAdapter {
  final String id;
  Map<String, dynamic>? _data;
  _FakeDocumentAdapter(this.id, [this._data]);
  @override
  Future<void> delete() async => _data = null;
  @override
  Future<Map<String, dynamic>?> get() async => _data;
  @override
  Future<void> set(Map<String, dynamic> data) async => _data = data;
  @override
  Future<void> update(Map<String, dynamic> data) async =>
      _data = {...?_data, ...data};
}

class _FakeCollectionAdapter implements CollectionAdapter {
  final Map<String, _FakeDocumentAdapter> store = {};
  @override
  DocumentAdapter doc(String id) =>
      store.putIfAbsent(id, () => _FakeDocumentAdapter(id));
}

class _FakeFirestoreAdapter implements FirestoreAdapter {
  final Map<String, _FakeCollectionAdapter> cols = {};
  @override
  CollectionAdapter collection(String name) =>
      cols.putIfAbsent(name, () => _FakeCollectionAdapter());
}

void main() {
  setUp(() {
    AuthService.clearInstanceForTests();
  });

  test('programmatic sign up writes user doc and sets currentUser', () async {
    final fakeAuth = _FakeAuthAdapter();
    final fakeFs = _FakeFirestoreAdapter();

    final service = AuthService(auth: fakeAuth, firestore: fakeFs);

    final err = await service.signUp(
      firstName: 'End',
      lastName: 'ToEnd',
      email: 'e2e+signup@example.com',
      password: 'password',
      confirmPassword: 'password',
      allergies: [],
    );

    expect(err, isNull);
    expect(service.currentUser, isNotNull);
    final doc = await fakeFs.collection('users').doc('uid_new').get();
    expect(doc, isNotNull);
    expect(doc!['email'], 'e2e+signup@example.com');
  });
}
