import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔐 SIGN UP (Email + Password)
  Future<UserCredential> signUp(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 🔐 LOGIN (Email + Password)
  Future<UserCredential> login(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 🔄 AUTH STATE STREAM (source of truth)
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  /// 👤 CURRENT USER
  User? get currentUser {
    return _auth.currentUser;
  }

  /// 🔑 GET FIREBASE ID TOKEN (for backend / ESP32 flow)
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
