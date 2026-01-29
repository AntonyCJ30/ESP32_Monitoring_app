class DashboardService {
  /// Fetch latest patient vitals
  /// Later this will come from BLE / API / MQTT
  Future<Map<String, dynamic>> fetchVitals() async {
    // Simulate IO delay
    await Future.delayed(const Duration(seconds: 1));

    return {
      "online": true,
      "heartRate": 70,
      "spo2": 98,
      "bodyTemperature": 36.8,
      "respirationRate": 16,
    };
  }
}
