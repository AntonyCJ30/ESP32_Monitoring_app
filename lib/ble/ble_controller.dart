import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_service.dart';

class BleController extends ChangeNotifier {
  final BleService _service;
  BleController(this._service);

  bool scanning = false;
  bool connected = false;
  String status = "Idle";

  final List<ScanResult> scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSub;

Future<void> init() async {
  await _service.init();

  FlutterBluePlus.isScanning.listen((isBleScanning) {
    scanning = isBleScanning;
    notifyListeners();
  });
}



  void toggleScan() {
  if (scanning) {
    stopScan();
  } else {
    startScan();
  }
}


 void startScan() {
  if (scanning) return; //  prevent double start

  status = "Scanning...";
  notifyListeners();

  _scanSub = _service.scan().listen((results) {
    scanResults
      ..clear()
      ..addAll(results);
    notifyListeners();
  });
}


 Future<void> stopScan() async {
  await _service.stopScan();
  await _scanSub?.cancel();
  _scanSub = null;

  status = "Scan stopped";
  notifyListeners();
}


  Future<void> connect(BluetoothDevice device) async {
    await stopScan();
    await _service.connect(device);

    connected = true;
    status = "Connected";
    notifyListeners();

    _service.txStream().listen((msg) {
      status = "Notify: $msg";
      notifyListeners();
    });
  }

  Future<void> sendCredentials(String ssid, String pass) async {
    await _service.sendJson({"ssid": ssid, "password": pass});
    status = "Credentials sent";
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _service.stopScan();
    _service.disconnect();
    super.dispose();
  }
}
