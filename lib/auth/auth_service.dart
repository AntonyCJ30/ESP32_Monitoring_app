import 'package:shared_preferences/shared_preferences.dart';
import 'token_storage.dart';

class AuthService {
  static const String _loginKey = 'is_logged_in';
  static const String _emailKey = 'user_email';

  /// LOGIN (mock for now)
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == "test@mediapp.com" && password == "123456") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loginKey, true);
      await prefs.setString(_emailKey, email);
      return true;
    }

    return false;
  }

  /// AUTO LOGIN CHECK
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  /// GET EMAIL
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    TokenStorage.deleteDeviceToken();
    await prefs.remove(_loginKey);
    await prefs.remove(_emailKey);
  }
}
