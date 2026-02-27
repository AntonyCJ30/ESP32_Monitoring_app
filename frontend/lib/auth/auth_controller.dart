import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service;

  AuthController(this._service) {
    print("Firebase user: ${FirebaseAuth.instance.currentUser}");
    _listenToAuthState();
  }

  Stream<User?> get authStateChanges => _service.authStateChanges;
  User? get currentUser => _service.currentUser;



  bool loading = true;
  bool loggedIn = false;
  String? error;
  String? _email;

  /// 🔹 Backend URL
  final String _baseUrl = "http://192.168.1.3:3000";

  /// 🔹 Getter for UI
  String get email => _email ?? 'Unknown';

  /// 🔄 Listen to Firebase Auth State
  void _listenToAuthState() {
    _service.authStateChanges.listen((User? user) async {
      if (user == null) {
        loggedIn = false;
        _email = null;
      } else {
        loggedIn = true;
        _email = user.email;

        // 🔐 Get Firebase ID token
        final token = await user.getIdToken(true);

        if (token != null) {
          await _sendTokenToBackend(token);
        }
      }

      loading = false;
      notifyListeners();
    });
  }

  /// 🔐 SIGN UP
  Future<bool> signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      error = "Email and password required";
      notifyListeners();
      return false;
    }

    try {
      loading = true;
      error = null;
      notifyListeners();

      await _service.signUp(email, password);
      return true; // listener handles backend sync
    } on FirebaseAuthException catch (e) {
      error = _mapFirebaseError(e);
      loading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔐 LOGIN
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
      return true; // listener handles backend sync
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
  }

  /// 🌐 Send Token to Backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/create-user"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Backend verified user");
      } else {
        print("Status: ${response.statusCode}");
                print("Body: ${response.body}");
      }
    } catch (e) {
      print("❌ Backend error: $e");
    }
  }

  /// 🔎 Firebase Error Mapper
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
