import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 SIGN UP (Email + Password)
  /// Creates:
  /// 1. Firebase Auth user
  /// 2. Firestore users/{uid} document (ONLY ONCE)
  Future<UserCredential> signUp(
    String email,
    String password,
  ) async {
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User user = credential.user!;

    // 🔥 Create Firestore user document
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'hasDevice': false,
    });

    return credential;
  }

  /// 🔐 LOGIN (Email + Password)
  /// Only authenticates — DOES NOT touch Firestore
  Future<UserCredential> login(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 🔄 AUTH STATE STREAM (single source of truth)
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  /// 👤 CURRENT USER
  User? get currentUser {
    return _auth.currentUser;
  }

  /// 🔑 GET FIREBASE ID TOKEN (for backend / ESP32)
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
