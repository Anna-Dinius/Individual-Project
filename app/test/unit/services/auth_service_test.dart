import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/auth_service.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';
import 'fake_firestore.dart';

// Minimal fakes for AuthService unit tests
class FakeUser {
  final String uid;
  final String? email;
  FakeUser(this.uid, [this.email]);
  Future<void> delete() async {}
  Future<void> updatePassword(String p) async {}
  Future<void> reauthenticateWithCredential(dynamic c) async {}
  Future<void> verifyBeforeUpdateEmail(String e) async {}
}

class FakeUserCredential {
  final FakeUser user;
  FakeUserCredential(this.user);
}

class FakeAuth {
  dynamic currentUser;
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return FakeUserCredential(FakeUser('uid123', email));
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    currentUser = FakeUser('uid123', email);
  }

  Future<void> signOut() async {
    currentUser = null;
  }
}

// Adapters that wrap the simple FakeAuth and FakeFirestore (top-level so
// they can be used inside tests without scoping issues).
class FakeUserAdapter implements UserAdapter {
  final FakeUser _u;
  FakeUserAdapter(this._u);
  @override
  String get uid => _u.uid;
  @override
  String? get email => _u.email;
  @override
  Future<void> delete() async => _u.delete();
  @override
  Future<void> updatePassword(String password) => _u.updatePassword(password);
  @override
  Future<void> reauthenticateWithCredential(dynamic credential) =>
      _u.reauthenticateWithCredential(credential);
  @override
  Future<void> verifyBeforeUpdateEmail(String email) =>
      _u.verifyBeforeUpdateEmail(email);
}

class FakeAuthAdapter implements AuthAdapter {
  FakeUserAdapter? _current;
  @override
  UserAdapter? get currentUser => _current;
  @override
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final u = FakeUser('uid123', email);
    _current = FakeUserAdapter(u);
    return {'user': _current};
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final u = FakeUser('uid123', email);
    _current = FakeUserAdapter(u);
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }
}

class FakeDocumentAdapterImpl implements DocumentAdapter {
  final FakeDocumentRef _ref;
  FakeDocumentAdapterImpl(this._ref);
  @override
  String get id => _ref.id;
  @override
  Future<Map<String, dynamic>?> get() async {
    final snap = await _ref.get();
    return snap.exists ? snap.data() : null;
  }

  @override
  Future<void> set(Map<String, dynamic> data) => _ref.set(data);
  @override
  Future<void> update(Map<String, dynamic> data) => _ref.update(data);
  @override
  Future<void> delete() => _ref.delete();
}

class FakeCollectionAdapterImpl implements CollectionAdapter {
  final List<FakeDocument> _docs;
  FakeCollectionAdapterImpl(this._docs);
  @override
  DocumentAdapter doc(String id) =>
      FakeDocumentAdapterImpl(FakeDocumentRef(id, _docs));
}

class FakeFirestoreAdapter implements FirestoreAdapter {
  final FakeFirestore _fs;
  FakeFirestoreAdapter(this._fs);
  @override
  CollectionAdapter collection(String name) =>
      FakeCollectionAdapterImpl(_fs.collections[name] ?? []);
}

void main() {
  group('AuthService (logic-only tests)', () {
    // Use the top-level FakeAuth/FakeUser/FakeUserCredential defined above.
    final fakeFs = FakeFirestore(
      {},
    ); // pass an empty fake Firestore to avoid Firebase initialization

    final fakeAuthAdapter = FakeAuthAdapter();
    final fakeFsAdapter = FakeFirestoreAdapter(fakeFs);

    test('signUp validation fails on password mismatch', () async {
      final service = AuthService(
        auth: fakeAuthAdapter,
        firestore: fakeFsAdapter,
      );
      final res = await service.signUp(
        firstName: 'F',
        lastName: 'L',
        email: 'a@a.com',
        password: '123456',
        confirmPassword: '123',
      );
      expect(res, contains('match'));
    });

    test('signUp validation fails on short password', () async {
      final service = AuthService(
        auth: fakeAuthAdapter,
        firestore: fakeFsAdapter,
      );
      final res = await service.signUp(
        firstName: 'F',
        lastName: 'L',
        email: 'a@a.com',
        password: '123',
        confirmPassword: '123',
      );
      expect(res, contains('at least'));
    });

    test('signIn validation fails on missing fields', () async {
      final service = AuthService(
        auth: fakeAuthAdapter,
        firestore: fakeFsAdapter,
      );
      final res = await service.signIn(email: '', password: '');
      expect(res, contains('required'));
    });

    test('verifyPassword returns false when no user', () async {
      final service = AuthService(
        auth: fakeAuthAdapter,
        firestore: fakeFsAdapter,
      );
      final ok = await service.verifyPassword('pwd');
      expect(ok, isFalse);
    });
  });
}
