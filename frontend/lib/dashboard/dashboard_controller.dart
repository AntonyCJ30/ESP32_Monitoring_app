import 'dart:async';
import 'package:flutter/material.dart';
import 'dashboard_state.dart';
import 'dashboard_service.dart';
import '../auth/auth_controller.dart';


class DashboardController extends ChangeNotifier {
  final DashboardService _service;
  final AuthController _authController;

  DashboardState _state = DashboardState.initial();
  DashboardState get state => _state;

  StreamSubscription? _vitalsSubscription;

  DashboardController(this._service, this._authController);

  /// Start listening to real-time vitals
Future<void> listenToVitals() async {
  final user = _authController.currentUser;
  if (user == null) return;

  _state = _state.copyWith(status: DashboardStatus.loading);
  notifyListeners();

  final deviceId = await _service.getFirstDeviceId(user.uid);

  if (deviceId == null) {
    _state = _state.copyWith(status: DashboardStatus.error);
    notifyListeners();
    return;
  }

  _vitalsSubscription?.cancel();

  _vitalsSubscription =
      _service.streamDevice(user.uid, deviceId).listen((data) {

    _state = _state.copyWith(
      status: DashboardStatus.ready,
      online: data['online'] as bool? ?? false,
      heartRate: data['heartRate'] as int? ?? 0,
      spo2: data['spo2'] as int? ?? 0,
      bodyTemperature:
          (data['bodyTemperature'] as num?)?.toDouble() ?? 0.0,
      respirationRate: data['respirationRate'] as int? ?? 0,
      lastUpdated: data['lastUpdated'] as DateTime?,
      deviceName: data['bedSide'] ?? "Patient Monitor",
      criticalAlert: _isCritical(data),
    );

    notifyListeners();
  });
}

 bool _isCritical(Map<String, dynamic> data) {
  final hr = (data['heartRate'] as num?)?.toInt() ?? 0;
  final spo2 = (data['spo2'] as num?)?.toInt() ?? 0;
  final temp = (data['bodyTemperature'] as num?)?.toDouble() ?? 0.0;

  return hr < 40 || hr > 120 || spo2 < 92 || temp > 38.0;
}

  /// Stop listening (IMPORTANT to avoid memory leaks)
  @override
  void dispose() {
    _vitalsSubscription?.cancel();
    super.dispose();
  }

  Future<void> logout() async {
    _vitalsSubscription?.cancel();
    await _authController.logout();
  }
}