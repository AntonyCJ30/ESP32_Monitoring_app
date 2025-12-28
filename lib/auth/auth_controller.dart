import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service;

  AuthController(this._service);

  bool loading = true;     // for splash / auto-login
  bool loggedIn = false;   // auth state
  String? error;           // error message for UI

  /// CALLED ON APP START (auto-login)
  Future<void> checkAutoLogin() async {
    loggedIn = await _service.isLoggedIn();
    loading = false;
    notifyListeners();
  }

  /// LOGIN CALLED FROM LoginScreen
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      error = "Email and password required";
      notifyListeners();
      return false;
    }

    loading = true;
    error = null;
    notifyListeners();

    final success = await _service.login(email, password);

    loading = false;
    loggedIn = success;

    if (!success) {
      error = "Invalid credentials";
    }

    notifyListeners();
    return success;
  }

  /// LOGOUT
  Future<void> logout() async {
    await _service.logout();
    loggedIn = false;
    notifyListeners();
  }
}
