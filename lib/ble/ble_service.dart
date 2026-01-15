import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ble_config.dart';

class BleService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar; // write
  BluetoothCharacteristic? _txChar; // notify

  final StringBuffer _rxBuffer = StringBuffer();

  // ---------- INIT ----------
  Future<void> init() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (!await FlutterBluePlus.isOn) {
      await FlutterBluePlus.turnOn();
    }
  }

  // ---------- SCAN ----------
  Stream<List<ScanResult>> scan() {
    FlutterBluePlus.startScan(
      androidScanMode: AndroidScanMode.lowLatency,
    );

    return FlutterBluePlus.scanResults.map(
      (results) => results
          .where((r) => r.advertisementData.serviceUuids
              .contains(BleConfig.provisioningService))
          .toList(),
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // ---------- CONNECT ----------
  Future<void> connect(BluetoothDevice device) async {
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
