import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceService {
  static const String _baseUrl = "http://192.168.1.3:3000";

  // 🔹 Check if device exists (used in AppEntryScreen)
  static Future<bool> hasPairedDevice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 🔹 Register device with backend
  static Future<void> registerDevice(String deviceToken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse("$_baseUrl/api/register-device"),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "deviceId": deviceToken,
      }),
    );
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    if (response.statusCode != 200) {
      throw Exception("Device registration failed");
    }
  }
}
