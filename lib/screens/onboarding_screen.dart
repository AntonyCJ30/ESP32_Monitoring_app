import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/ble_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  final ssidCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    ssidCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BleController>();

    return Scaffold(
      appBar: AppBar(title: const Text("BLE Onboarding")),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: "Scan"),
              Tab(text: "Provision"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                /// SCAN TAB
                Column(
                  children: [
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.toggleScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.scanning
                            ? Colors.red
                            : Colors.blue,
                      ),
                      child: Text(
                        controller.scanning
                            ? "Stop BLE Scan"
                            : "Start BLE Scan",
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.scanResults.length,
                        itemBuilder: (_, i) {
                          final ScanResult r =
                              controller.scanResults[i];
                          return ListTile(
                            title: Text(
                              r.advertisementData.advName.isNotEmpty
                                  ? r.advertisementData.advName
                                  : "Unknown Device",
                            ),
                            subtitle: Text(r.device.id.id),
                            trailing: ElevatedButton(
                              onPressed: () =>
                                  controller.connect(r.device),
                              child: const Text("Connect"),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                /// PROVISION TAB
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        controller.connected
                            ? "Connected"
                            : "Not connected",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ssidCtrl,
                        decoration: const InputDecoration(
                          labelText: "Wi-Fi SSID",
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Wi-Fi Password",
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.connected
                            ? () => controller.sendCredentials(
                                  ssidCtrl.text,
                                  passCtrl.text,
                                )
                            : null,
                        child: const Text("Send Credentials"),
                      ),
                      const SizedBox(height: 12),
                      Text("Status: ${controller.status}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
