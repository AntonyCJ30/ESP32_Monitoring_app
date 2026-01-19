import 'dart:async';

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
  void initState() {
    super.initState();

    _controller = context.read<BleController>();


  Timer.periodic(const Duration(seconds: 5), (t) {
  if (!mounted) {
    t.cancel();
    return;
  }

  if (_controller.state == BleState.scanning) {
    _controller.startScan(); // clears list and rescans
  }
});


    // -------- listen for connection -> navigate --------
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

    // -------- auto start scanning --------
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.scanning) {
        _controller.startScan();
      }
    });
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
      appBar: AppBar(
        title: const Text("Find Device"),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          /// STATUS
          Text(
            isConnecting
                ? "Connecting to device..."
                : "Searching for nearby devices",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          /// DEVICE LIST OR LOADER
         Expanded(
  child: controller.scanResults.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                controller.statusMessage.isNotEmpty
                    ? controller.statusMessage
                    : "Searching for nearby devices...",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      : ListView.builder(
          itemCount: controller.scanResults.length,
          itemBuilder: (_, i) {
            final r = controller.scanResults[i];

            final name =
                r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : "ESP32 Device";

            return Card(
              child: ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(name),
                subtitle: Text(r.device.id.id),
                trailing: ElevatedButton(
                  onPressed: isConnecting
                      ? null
                      : () => controller.connect(r.device),
                  child: const Text("Connect"),
                ),
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
