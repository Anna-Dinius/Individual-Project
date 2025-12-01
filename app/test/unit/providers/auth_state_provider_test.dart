import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';
import 'package:nomnom_safe/services/auth_service.dart';

class _FakeUserAdapter implements UserAdapter {
  final String uid;
  final String? email;
  bool reauthThrows = false;

  _FakeUserAdapter(this.uid, {this.email});

  @override
  Future<void> delete() async {}

  @override
  Future<void> reauthenticateWithCredential(dynamic credential) async {
    if (reauthThrows) throw Exception('reauth failed');
  }

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> verifyBeforeUpdateEmail(String email) async {}
}

class _FakeAuthAdapter implements AuthAdapter {
  _FakeUserAdapter? _user;

  _FakeAuthAdapter([this._user]);

  @override
  UserAdapter? get currentUser => _user;

  @override
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = _FakeUserAdapter('newid', email: email);
    return {'user': _user};
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // create a user to simulate sign-in
    _user = _FakeUserAdapter('signedin', email: email);
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
  Future<void> delete() async {
    _data = null;
  }

  @override
  Future<Map<String, dynamic>?> get() async => _data;

  @override
  Future<void> set(Map<String, dynamic> data) async {
    _data = data;
  }

  @override
  Future<void> update(Map<String, dynamic> data) async {
    _data = {...?_data, ...data};
  }
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
  group('AuthStateProvider', () {
    setUp(() {
      // Ensure AuthService singleton is reset so each test can inject fakes
      AuthService.clearInstanceForTests();
    });
    test('verifyPassword returns true when underlying auth succeeds', () async {
      final fakeAuth = _FakeAuthAdapter(
        _FakeUserAdapter('u1', email: 'a@b.com'),
      );
      final fakeFs = _FakeFirestoreAdapter();
      // create custom AuthService using adapters
      final service = AuthService(auth: fakeAuth, firestore: fakeFs);
      final provider = AuthStateProvider(service);

      final ok = await provider.verifyPassword('pw');
      expect(ok, isTrue);
    });

    test('verifyPassword returns false on exception', () async {
      final fakeUser = _FakeUserAdapter('u1', email: 'a@b.com')
        ..reauthThrows = true;
      final fakeAuth = _FakeAuthAdapter(fakeUser);
      final fakeFs = _FakeFirestoreAdapter();
      final service = AuthService(auth: fakeAuth, firestore: fakeFs);
      final provider = AuthStateProvider(service);

      final ok = await provider.verifyPassword('pw');
      expect(ok, isFalse);
    });

    test('updatePassword returns validation errors from service', () async {
      final fakeAuth = _FakeAuthAdapter(
        _FakeUserAdapter('u1', email: 'a@b.com'),
      );
      final fakeFs = _FakeFirestoreAdapter();
      final service = AuthService(auth: fakeAuth, firestore: fakeFs);
      final provider = AuthStateProvider(service);

      // too short
      final err = await provider.updatePassword(
        newPassword: 'x',
        confirmPassword: 'x',
      );
      expect(err, isNotNull);
    });

    test(
      'deleteAccount throws when verifyPassword fails and succeeds otherwise',
      () async {
        final fakeUser = _FakeUserAdapter('u1', email: 'a@b.com');
        final fakeAuth = _FakeAuthAdapter(fakeUser);
        final fakeFs = _FakeFirestoreAdapter();
        final service = AuthService(auth: fakeAuth, firestore: fakeFs);
        final provider = AuthStateProvider(service);

        // success path: no exception
        await provider.deleteAccount(password: 'pw');

        // make reauth fail
        fakeUser.reauthThrows = true;
        final provider2 = AuthStateProvider(service);
        expect(() => provider2.deleteAccount(password: 'pw'), throwsException);
      },
    );

    test('currentUser proxies to underlying service', () async {
      final fakeUser = _FakeUserAdapter('u1', email: 'a@b.com');
      final fakeAuth = _FakeAuthAdapter(fakeUser);
      final fakeFs = _FakeFirestoreAdapter();
      // ensure a user document exists in the fake firestore so loadCurrentUser can populate
      await fakeFs.collection('users').doc('u1').set({
        'first_name': 'A',
        'last_name': 'B',
        'email': 'a@b.com',
        'allergies': <String>[],
      });

      final service = AuthService(auth: fakeAuth, firestore: fakeFs);
      // load the current user into the service
      await service.loadCurrentUser();

      final provider = AuthStateProvider(service);

      final u = provider.currentUser;
      expect(u, isNotNull);
      expect(u!.id, 'u1');
    });
  });
}
