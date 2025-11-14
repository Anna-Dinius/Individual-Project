import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

/// AuthService manages user authentication and session state using Firebase Firestore.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  /// Get the currently logged-in user, or null if not authenticated
  User? get currentUser => _currentUser;

  /// Check if a user is currently logged in
  bool get isSignedIn => _currentUser != null;

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
      // Check if email already exists in Firestore
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('Email already in use');
      }

      // Create new user document in Firestore
      final docRef = _firestore.collection('users').doc();
      final newUser = User(
        id: docRef.id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password, // Note: In production, hash this before storing!
        allergies: allergies ?? [],
      );

      await docRef.set(newUser.toJson());
      _currentUser = newUser;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }

  /// Sign in with email and password.
  /// Throws Exception if credentials are invalid.
  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    try {
      // Query Firestore for user with matching email and password
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Invalid email or password');
      }

      // Load user from Firestore document
      final userDoc = querySnapshot.docs.first;
      _currentUser = User.fromJson({...userDoc.data(), 'id': userDoc.id});
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _currentUser = null;
  }

  /// Update the current user's profile information
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    List<String>? allergies,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    if (firstName.isEmpty || lastName.isEmpty) {
      throw Exception('First name and last name are required');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Valid email is required');
    }
    if (password.isEmpty || password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    try {
      // Check if new email is already in use by another user
      if (email != _currentUser!.email) {
        final existingUser = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (existingUser.docs.isNotEmpty) {
          throw Exception('Email already in use');
        }
      }

      // Create updated user object
      final updatedUser = User(
        id: _currentUser!.id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        allergies: allergies ?? [],
      );

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .set(updatedUser.toJson());

      _currentUser = updatedUser;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }
}
