import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔐 SIGN UP
  Future<UserCredential> signUp(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 🔐 LOGIN
  Future<UserCredential> login(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 🔄 AUTH STATE STREAM
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 👤 CURRENT USER
  User? get currentUser => _auth.currentUser;

  /// 🔑 GET FRESH ID TOKEN
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(true); // force refresh
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}