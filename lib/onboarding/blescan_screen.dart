import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ble/ble_controller.dart';
import '../ble/ble_state.dart';
import 'provision_screen.dart';

class ScanScreen extends StatefulWidget {
  static const routeName = '/scan';
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late BleController _controller;
  late VoidCallback _listener;
  bool _navigated = false;

  @override
@override
void initState() {
  super.initState();

  _controller = context.read<BleController>();

  _listener = () {
    debugPrint("SCAN LISTENER STATE = ${_controller.state}");

    if (_controller.state == BleState.connected && !_navigated) {
      _navigated = true;
      debugPrint("NAVIGATING TO PROVISION");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProvisionScreen()),
      );
    }

    if (_controller.state == BleState.idle ||
        _controller.state == BleState.error) {
      _navigated = false;
    }
  };

  _controller.addListener(_listener);
}

  @override
  void dispose() {
    _controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BleController>();

    final bool isConnecting =
        controller.state == BleState.connecting;

    return Scaffold(
      appBar: AppBar(title: const Text("Scan for Device")),
      body: Column(
        children: [
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: controller.toggleScan,
            child: Text(
              controller.scanning
                  ? "Stop BLE Scan"
                  : "Start BLE Scan",
            ),
          ),

          const SizedBox(height: 8),

          Text(
            controller.statusMessage,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: controller.scanResults.length,
              itemBuilder: (_, i) {
                final r = controller.scanResults[i];

                return ListTile(
                  title: Text(
                    r.advertisementData.advName.isNotEmpty
                        ? r.advertisementData.advName
                        : "Unknown Device",
                  ),
                  subtitle: Text(r.device.id.id),
                  trailing: ElevatedButton(
                    onPressed: isConnecting
                        ? null
                        : () => controller.connect(r.device),
                    child: const Text("Connect"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
