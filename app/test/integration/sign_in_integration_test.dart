import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/screens/sign_in_screen.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/adapters/auth_adapter.dart';
import 'package:nomnom_safe/services/adapters/firestore_adapter.dart';
import 'package:nomnom_safe/services/auth_service.dart';

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

  testWidgets('Sign in flow updates provider currentUser', (
    WidgetTester tester,
  ) async {
    final fakeAuth = _FakeAuthAdapter();
    final fakeFs = _FakeFirestoreAdapter();
    // create fake user doc so AuthService.loadCurrentUser can populate
    await fakeFs.collection('users').doc('signedin').set({
      'first_name': 'A',
      'last_name': 'B',
      'email': 'a@b.com',
      'allergies': <String>[],
    });

    final service = AuthService(auth: fakeAuth, firestore: fakeFs);
    final provider = AuthStateProvider(service);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthStateProvider>.value(
        value: provider,
        child: MaterialApp(home: Scaffold(body: SignInScreen())),
      ),
    );
    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);

    // fill email and password
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('emailField')),
        matching: find.byType(EditableText),
      ),
      'a@b.com',
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('passwordField')),
        matching: find.byType(EditableText),
      ),
      'password',
    );

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // provider should now have a currentUser
    expect(provider.currentUser, isNotNull);
  });
}
