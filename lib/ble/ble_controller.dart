import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_service.dart';
import 'ble_state.dart';
import '../auth/token_storage.dart';

class BleController extends ChangeNotifier {
  final BleService _service;
  BleController(this._service);

  // ---------- STATE ----------
  BleState state = BleState.idle;
  String statusMessage = "Idle";

  bool scanning = false;
  bool provisioning = false;

  bool wifiOk = false;
  String? deviceToken;

  final List<ScanResult> scanResults = [];

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<String>? _rxSub;

  // ---------- INIT ----------
  Future<void> init() async {
    await _service.init();

    FlutterBluePlus.isScanning.listen((s) {
      scanning = s;
      notifyListeners();
    });
  }

  // ---------- SCAN ----------
  void toggleScan() {
    scanning ? stopScan() : startScan();
  }

  void startScan() {
    state = BleState.scanning;
    statusMessage = "Scanning...";
    notifyListeners();

    _scanSub = _service.scan().listen((results) {
      for (final r in results) {
        if (!scanResults.any((e) => e.device.id == r.device.id)) {
          scanResults.add(r);
        }
      }
      notifyListeners();
    });
  }

  Future<void> stopScan() async {
    await _service.stopScan();
    await _scanSub?.cancel();
    _scanSub = null;

    state = BleState.idle;
    statusMessage = "Scan stopped";
    notifyListeners();
  }

  // ---------- CONNECT ----------
  Future<void> connect(BluetoothDevice device) async {
    try {
      await stopScan();

      state = BleState.connecting;
      statusMessage = "Connecting...";
      notifyListeners();

      await _service.connect(device);

      state = BleState.connected;
      statusMessage = "Connected to device";
      notifyListeners();

      _rxSub = _service.txStream().listen(_handleMessage);
    } catch (e) {
      state = BleState.error;
      statusMessage = "Connection failed";
      notifyListeners();
    }
  }

  // ---------- SEND WIFI ----------
  Future<void> sendCredentials(String ssid, String pass) async {
    if (state != BleState.connected) return;

    provisioning = true;
    state = BleState.provisioning;
    statusMessage = "Sending Wi-Fi credentials...";
    notifyListeners();

    await _service.sendJson({
      "ssid": ssid,
      "password": pass,
    });
  }

  // ---------- RX ----------
  void _handleMessage(String msg) async {
    debugPrint("BLE MSG => $msg");

    if (msg == "WIFI_OK") {
      wifiOk = true;
      state = BleState.wifiConnected;
      statusMessage = "Wi-Fi connected  Waiting for Token";
      notifyListeners();
    }

    else if (msg == "WIFI_FAIL") {
      wifiOk = false;
      state = BleState.wifiFailed;
      statusMessage = "Wi-Fi failed";
    }

    else if (msg.startsWith("TOKEN:")) {
      final token = msg.substring(6).trim();

      await TokenStorage.saveDeviceToken(token);
      deviceToken = token;

      provisioning = false;
      state = BleState.provisioned;
      statusMessage = "Provisioning complete";
    }

    notifyListeners();
  }

  // ---------- RESET ----------
  Future<void> resetProvisioning() async {
    state = BleState.idle;
    statusMessage = "Idle";

    provisioning = false;
    wifiOk = false;
    deviceToken = null;
    scanResults.clear();

    await _service.disconnect();
    notifyListeners();
  }

  // ---------- CLEANUP ----------
  @override
  void dispose() {
    _scanSub?.cancel();
    _rxSub?.cancel();
    _service.disconnect();
    super.dispose();
  }
}
