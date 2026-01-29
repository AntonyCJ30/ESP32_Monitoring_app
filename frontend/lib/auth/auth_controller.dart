import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service;

  AuthController(this._service) {
    _listenToAuthState();
  }

  bool loading = true;      // splash / initial load
  bool loggedIn = false;    // auth state
  String? error;            // error message for UI

  String? _email;

  /// READ-ONLY GETTER FOR UI
  String get email => _email ?? 'Unknown';

  /// 🔄 LISTEN TO FIREBASE AUTH STATE
  void _listenToAuthState() {
    _service.authStateChanges.listen((User? user) {
      if (user == null) {
        // Logged out
        loggedIn = false;
        _email = null;
      } else {
        // Logged in
        loggedIn = true;
        _email = user.email;
      }

      loading = false;
      notifyListeners();
    });
  }

  /// 🔐 LOGIN (Email + Password)
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      error = "Email and password required";
      notifyListeners();
      return false;
    }

    try {
      loading = true;
      error = null;
      notifyListeners();

      await _service.login(email, password);
      // Success will be reflected automatically via authStateChanges
      return true;
    } on FirebaseAuthException catch (e) {
      error = _mapFirebaseError(e);
      loading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔐 SIGN UP (optional but recommended)
  Future<bool> signUp(String email, String password) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _service.signUp(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      error = _mapFirebaseError(e);
      loading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _service.logout();
    // authStateChanges will handle state reset
  }

  /// 🔎 MAP FIREBASE ERRORS TO UI-FRIENDLY TEXT
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed. Try again.';
    }
  }
}
