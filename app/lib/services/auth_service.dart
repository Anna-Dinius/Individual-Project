import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_safe/models/user.dart';

/// AuthService manages user authentication and session state using Firebase Firestore.
class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  static final AuthService _instance = AuthService._internal();

  User? _currentUser;

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  /// Get the currently logged-in user, or null if not authenticated
  User? get currentUser => _currentUser;

  Future<void> loadCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser != null) {
      final userDoc = await _firestore
          .collection('users')
          .doc(fbUser.uid)
          .get();
      if (userDoc.exists) {
        _currentUser = User.fromJson({...userDoc.data()!, 'id': fbUser.uid});
      }
    }
  }

  /// Check if a user is currently logged in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign up a new user with validation.
  Future<String?> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    // Validate inputs
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    if (password.isEmpty || password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      final newUser = User(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        allergies: allergies ?? [],
      );

      await _firestore.collection('users').doc(uid).set(newUser.toJson());
      _currentUser = newUser;
    } on fb_auth.FirebaseAuthException {
      return 'Error signing up.';
    }

    return null;
  }

  /// Sign in with email and password.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required';
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = _auth.currentUser!.uid;

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return 'User profile not found';

      _currentUser = User.fromJson({...userDoc.data()!, 'id': uid});
    } on fb_auth.FirebaseAuthException {
      return 'Error signing in.';
    }

    return null;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  /// Update the current user's profile information
  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    final fbUser = _auth.currentUser;
    final uid = fbUser?.uid;
    if (uid == null || _currentUser == null) {
      return 'No user is currently signed in';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    final updates = <String, dynamic>{};

    // Compare each field
    if (firstName != _currentUser!.firstName) updates['first_name'] = firstName;
    if (lastName != _currentUser!.lastName) updates['last_name'] = lastName;
    if (allergies != null &&
        allergies.toSet() != _currentUser!.allergies.toSet()) {
      updates['allergies'] = allergies;
    }

    // Handle email change
    if (email != fbUser?.email) {
      await fbUser?.verifyBeforeUpdateEmail(email);
      updates['pending_email'] = email;
    }

    // Only write if something changed
    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
      await loadCurrentUser(); // Refresh local copy
    }

    return null; // success
  }

  Future<bool> verifyPassword(String password) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || fbUser.email == null) {
      return false;
    }

    final credential = fb_auth.EmailAuthProvider.credential(
      email: fbUser.email!,
      password: password,
    );

    try {
      await fbUser.reauthenticateWithCredential(credential);
      return true;
    } on fb_auth.FirebaseAuthException {
      return false;
    }
  }

  /// Update password with confirmation, return error string if invalid
  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return 'No user is currently signed in';
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }

    try {
      await fbUser.updatePassword(newPassword);
      return null; // success
    } on fb_auth.FirebaseAuthException {
      return 'Password update failed.';
    }
  }

  Future<String?> deleteAccount() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return 'No user is currently signed in';
    }

    try {
      // Delete Firestore user document
      await _firestore.collection('users').doc(fbUser.uid).delete();

      // Delete Firebase Auth user
      await fbUser.delete();

      // Clear local state
      _currentUser = null;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please log in again before deleting your account.';
      } else {
        return 'Account deletion failed.';
      }
    } catch (e) {
      return 'Unexpected error.';
    }

    return null;
  }
}
