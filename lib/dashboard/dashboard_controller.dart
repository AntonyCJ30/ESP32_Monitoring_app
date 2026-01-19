import 'package:flutter/material.dart';
import 'dashboard_state.dart';
import 'dashboard_service.dart';
import '../auth/auth_controller.dart';

class DashboardController extends ChangeNotifier {
  final DashboardService _service;
  final AuthController _authController;

  DashboardState _state = DashboardState.initial();
  DashboardState get state => _state;

  DashboardController(this._service,this._authController);

  /// Load dashboard data
  Future<void> loadDashboard() async {
    _state = _state.copyWith(status: DashboardStatus.loading);
    notifyListeners();

    try {
      final data = await _service.fetchVitals();

      _state = _state.copyWith(
        status: DashboardStatus.ready,
        online: data['online'] as bool,
        heartRate: data['heartRate'] as int,
        spo2: data['spo2'] as int,
        bodyTemperature: data['bodyTemperature'] as double,
        respirationRate: data['respirationRate'] as int,
        lastUpdated: DateTime.now(),
        criticalAlert: _isCritical(data),
      );
    } catch (e) {
      _state = _state.copyWith(status: DashboardStatus.error);
    }

    notifyListeners();
  }

  bool _isCritical(Map<String, dynamic> data) {
    final hr = data['heartRate'] as int;
    final spo2 = data['spo2'] as int;
    final temp = data['bodyTemperature'] as double;

    return hr < 40 || hr > 120 || spo2 < 92 || temp > 38.0;
  }

  Future<void> refresh() async {
    await loadDashboard();
  }

  Future<void> logout() async {
        debugPrint("🔥 DashboardController.logout called");
      _authController.logout();
  }
}
