import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ble_config.dart';

class BleService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar;
  BluetoothCharacteristic? _txChar;

  final StringBuffer _rxBuffer = StringBuffer();

  bool _initialized = false;
  bool _isScanning = false;

  // ---------- INIT (run once) ----------
  Future<void> init() async {
    if (_initialized) return;

    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (!await FlutterBluePlus.isOn) {
      await FlutterBluePlus.turnOn();
    }

    _initialized = true;
  }

  // ---------- SCAN CONTROL ----------
  Stream<List<ScanResult>> scanResults() => FlutterBluePlus.scanResults;

  Future<void> startScan() async {
    if (_isScanning) return;

    print("START SCAN CALLED");

    print(await FlutterBluePlus.adapterState.first);

    await init();

    _isScanning = true;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    Future.delayed(const Duration(seconds: 10), () {
      _isScanning = false;
    });
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;
    await FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  // ---------- CONNECT ----------
  Future<void> connect(BluetoothDevice device) async {
    if (_device?.remoteId == device.remoteId) return;

    _device = device;

    await _device!.connect(
      timeout: const Duration(seconds: 10),
      autoConnect: false,
    );

    try {
      await _device!.requestMtu(247);
    } catch (_) {}

    await _discoverServices();
  }

  Future<void> _discoverServices() async {
    final services = await _device!.discoverServices();

    for (final s in services) {
      if (s.uuid == BleConfig.provisioningService) {
        for (final c in s.characteristics) {
          if (c.uuid == BleConfig.rx) _rxChar = c;
          if (c.uuid == BleConfig.tx) {
            _txChar = c;
            await _txChar!.setNotifyValue(true);
          }
        }
      }
    }
  }

  // ---------- RX STREAM ----------
  Stream<String> txStream() {
    if (_txChar == null) return const Stream.empty();

    return _txChar!.onValueReceived
        .map((chunk) => utf8.decode(chunk))
        .expand((data) {
          _rxBuffer.write(data);
          final buffer = _rxBuffer.toString();

          if (!buffer.contains('\n')) return [];

          final parts = buffer.split('\n');
          _rxBuffer.clear();
          _rxBuffer.write(parts.last);

          return parts.take(parts.length - 1);
        });
  }

  // ---------- SEND ----------
  Future<void> sendJson(Map<String, dynamic> data) async {
    if (_rxChar == null) return;
    final payload = utf8.encode(jsonEncode(data) + '\n');
    await _rxChar!.write(payload, withoutResponse: false);
  }

  Future<void> sendRaw(String msg) async {
    if (_rxChar == null) return;
    final payload = utf8.encode(msg + '\n');
    await _rxChar!.write(payload, withoutResponse: false);
  }

  // ---------- DISCONNECT ----------
  Future<void> disconnect() async {
    try {
      await _txChar?.setNotifyValue(false);
    } catch (_) {}

    await _device?.disconnect();

    _device = null;
    _rxChar = null;
    _txChar = null;
    _rxBuffer.clear();
  }
}