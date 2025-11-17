import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_safe/models/user.dart';

/// AuthService manages user authentication and session state using Firebase Firestore.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

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
  /// Throws Exception if email already exists or validation fails.
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    // Validate inputs
    if (firstName.isEmpty || lastName.isEmpty) {
      throw Exception('First name and last name are required');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Valid email is required');
    }
    if (password.isEmpty || password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
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
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception('Auth error: ${e.code}');
    }
  }

  /// Sign in with email and password.
  /// Throws Exception if credentials are invalid.
  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = _auth.currentUser!.uid;

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception('User profile not found');

      _currentUser = User.fromJson({...userDoc.data()!, 'id': uid});
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception('Auth error: ${e.code}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  /// Update the current user's profile information
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    List<String>? allergies,
  }) async {
    final fbUser = _auth.currentUser;
    final uid = fbUser?.uid;
    if (uid == null || _currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    final updates = <String, dynamic>{};

    if (firstName.isEmpty || lastName.isEmpty) {
      throw Exception('First name and last name are required');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Valid email is required');
    }
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
  }

  Future<bool> reauthenticate(String password) async {
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
    } on fb_auth.FirebaseAuthException catch (_) {
      return false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      throw Exception('No user is currently signed in');
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    try {
      await fbUser.updatePassword(newPassword);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception('Password update failed: ${e.code}');
    }
  }

  Future<void> deleteAccount() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      throw Exception('No user is currently signed in');
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
        throw Exception('Please log in again before deleting your account.');
      } else {
        throw Exception('Account deletion failed: ${e.code}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
