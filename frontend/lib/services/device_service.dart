import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeviceService {
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
}
