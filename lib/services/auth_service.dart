import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? _safeAuth(),
        _firestore = firestore ?? _safeFirestore();

  static FirebaseAuth? _safeAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _safeFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Current authenticated Firebase user
  User? get currentUser => _auth?.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? Stream<User?>.value(null);

  /// Retrieve current user profile from Firestore or fallback to Auth profile
  Future<UserModel?> getCurrentUserProfile() async {
    final User? user = _auth?.currentUser;
    if (user == null) return null;

    final fs = _firestore;
    if (fs != null) {
      try {
        final doc = await fs.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (_) {
        // Fallback below
      }
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? (user.email?.split('@').first ?? 'RigCrafter'),
      role: 'user',
    );
  }

  /// Register a new user with Email and Password
  /// Creates the Firebase Auth credential, sets display name, and writes profile to Firestore.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase Auth is not initialized.');
    }

    final UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final User? user = credential.user;
    if (user == null) {
      throw Exception('User registration failed. Please try again.');
    }

    // Update display name in Firebase Auth
    await user.updateDisplayName(name.trim());

    final DateTime now = DateTime.now();

    // Store user profile in Cloud Firestore under 'users/{uid}'
    final fs = _firestore;
    if (fs != null) {
      await fs.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return UserModel(
      id: user.uid,
      email: email.trim(),
      name: name.trim(),
      role: 'user',
      createdAt: now,
    );
  }

  /// Sign in an existing user with Email and Password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase Auth is not initialized.');
    }

    final UserCredential credential = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final User? user = credential.user;
    if (user == null) {
      throw Exception('Login failed. Please try again.');
    }

    // Attempt to load Firestore profile data
    final fs = _firestore;
    if (fs != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> doc =
            await fs.collection('users').doc(user.uid).get();

        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (_) {
        // Fallback if Firestore query fails
      }
    }

    return UserModel(
      id: user.uid,
      email: user.email ?? email.trim(),
      name: user.displayName ?? (email.split('@').first),
      role: 'user',
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth?.signOut();
  }
}
