enum DashboardStatus {
  loading,
  ready,
  error,
  offline,
}

class DashboardState {
  final DashboardStatus status;

  // Device / patient info
  final String deviceName;
  final bool online;
  final DateTime? lastUpdated;

  // Medical vitals
  final int heartRate;          // bpm
  final int spo2;               // %
  final double bodyTemperature; // °C
  final int respirationRate;    // breaths/min

  // Alert
  final bool criticalAlert;

  const DashboardState({
    required this.status,
    required this.deviceName,
    required this.online,
    required this.lastUpdated,
    required this.heartRate,
    required this.spo2,
    required this.bodyTemperature,
    required this.respirationRate,
    required this.criticalAlert,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      status: DashboardStatus.loading,
      deviceName: "Patient Monitor",
      online: false,
      lastUpdated: null,
      heartRate: 0,
      spo2: 0,
      bodyTemperature: 0.0,
      respirationRate: 0,
      criticalAlert: false,
    );
  }

  DashboardState copyWith({
    DashboardStatus? status,
    String? deviceName,
    bool? online,
    DateTime? lastUpdated,
    int? heartRate,
    int? spo2,
    double? bodyTemperature,
    int? respirationRate,
    bool? criticalAlert,
  }) {
    return DashboardState(
      status: status ?? this.status,
      deviceName: deviceName ?? this.deviceName,
      online: online ?? this.online,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      respirationRate: respirationRate ?? this.respirationRate,
      criticalAlert: criticalAlert ?? this.criticalAlert,
    );
  }
}
