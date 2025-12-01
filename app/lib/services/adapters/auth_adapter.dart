import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// Adapter interfaces for authentication so AuthService can be unit-tested
/// without depending directly on the Firebase SDK.

abstract class UserAdapter {
  String get uid;
  String? get email;
  Future<void> delete();
  Future<void> updatePassword(String password);
  Future<void> reauthenticateWithCredential(dynamic credential);
  Future<void> verifyBeforeUpdateEmail(String email);
}

abstract class AuthAdapter {
  UserAdapter? get currentUser;
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

// Production adapter (wraps FirebaseAuth) is implemented in the same file
// to keep the change minimal. It uses the Firebase SDK when available.

class FirebaseUserAdapter implements UserAdapter {
  final fb_auth.User _user;
  FirebaseUserAdapter(this._user);

  @override
  String get uid => _user.uid;

  @override
  String? get email => _user.email;

  @override
  Future<void> delete() => _user.delete();

  @override
  Future<void> updatePassword(String password) =>
      _user.updatePassword(password);

  @override
  Future<void> reauthenticateWithCredential(dynamic credential) =>
      _user.reauthenticateWithCredential(credential);

  @override
  Future<void> verifyBeforeUpdateEmail(String email) =>
      _user.verifyBeforeUpdateEmail(email);
}

class FirebaseAuthAdapter implements AuthAdapter {
  final fb_auth.FirebaseAuth _auth;
  FirebaseAuthAdapter([fb_auth.FirebaseAuth? auth])
    : _auth = auth ?? fb_auth.FirebaseAuth.instance;

  @override
  UserAdapter? get currentUser => _auth.currentUser == null
      ? null
      : FirebaseUserAdapter(_auth.currentUser!);

  @override
  Future<dynamic> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => _auth.createUserWithEmailAndPassword(email: email, password: password);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _auth
      .signInWithEmailAndPassword(email: email, password: password)
      .then((_) {});

  @override
  Future<void> signOut() => _auth.signOut();
}
