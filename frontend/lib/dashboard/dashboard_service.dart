import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> streamDevice(
    String userId,
    String deviceId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {};
      }

       final data = snapshot.data()!;

       return {
      ...data,
      "lastUpdated":
          (data["lastUpdated"] as Timestamp?)?.toDate(),
    };

      
    });
  }

  Future<String?> getFirstDeviceId(String userId) async {
  final snapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('devices')
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return null;

  return snapshot.docs.first.id;
}
}