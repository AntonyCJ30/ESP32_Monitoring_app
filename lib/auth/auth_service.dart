import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loginKey = 'is_logged_in';

  /// LOGIN (mock for now)
  Future<bool> login(String email, String password) async {
    // simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // mock credentials
    if (email == "test@mediapp.com" && password == "123456") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loginKey, true);
      return true;
    }

    return false;
  }

  /// AUTO LOGIN CHECK (on app start)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
  }
}
