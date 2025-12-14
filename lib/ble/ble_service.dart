import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ble_config.dart';





class BleService {
  BluetoothDevice? device;
  BluetoothCharacteristic? rxChar;
  BluetoothCharacteristic? txChar;

  /// INIT BLE
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

  /// SCAN (UUID BASED)
  Stream<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 8)}) {
    FlutterBluePlus.startScan(timeout: timeout);

    return FlutterBluePlus.scanResults.map((results) {
      return results
          .where((r) =>
              r.advertisementData.serviceUuids.contains(BleConfig.provisioningService))
          .toList();
    });
  }

  /// CONNECT
  Future<void> connect(BluetoothDevice d) async {
    device = d;
    await device!.connect(timeout: const Duration(seconds: 10));
    await _discoverServices();
  }

  /// DISCOVER SERVICES
  Future<void> _discoverServices() async {
    final services = await device!.discoverServices();

    for (final s in services) {
      if (s.uuid == BleConfig.provisioningService) {
        for (final c in s.characteristics) {
          if (c.uuid == BleConfig.rx) rxChar = c;
          if (c.uuid == BleConfig.tx) {
            txChar = c;
            await txChar!.setNotifyValue(true);
          }
        }
      }
    }
  }

  /// LISTEN TX
  Stream<String> txStream() {
    if (txChar == null) return const Stream.empty();

    return txChar!.value.map((data) {
      return utf8.decode(data);
    });
  }

  /// WRITE RX
  Future<void> sendJson(Map<String, dynamic> data) async {
    if (rxChar == null) return;

    final payload = jsonEncode(data);
    await rxChar!.write(
      utf8.encode(payload),
      withoutResponse: true,
    );
  }

  /// DISCONNECT
  Future<void> disconnect() async {
    await device?.disconnect();
    device = null;
  }
}
