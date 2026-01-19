import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ble/ble_controller.dart';
import '../ble/ble_state.dart';
import '../routes/dashboard_route.dart';
import 'blescan_screen.dart';

class ProvisionScreen extends StatefulWidget {
  static const routeName = '/provision';
  const ProvisionScreen({super.key});

  @override
  State<ProvisionScreen> createState() => _ProvisionScreenState();
}

class _ProvisionScreenState extends State<ProvisionScreen> {
  final TextEditingController ssidCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool _navigated = false;

  @override
  void dispose() {
    ssidCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
 @override
Widget build(BuildContext context) {
  final controller = context.watch<BleController>();

  debugPrint(
    "BUILD → state=${controller.state}, "
    "prov=${controller.provisioning}, "
    "token=${controller.deviceToken}",
  );

  // Navigate on success
  if (controller.state == BleState.provisioned && !_navigated) {
    _navigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(
        DashboardRoute.routeName,
        (_) => false,
      );
    });
  }

  final bool canSend =
      controller.selectedSsid != null &&
      !controller.provisioning &&
      controller.deviceToken == null;

  return Scaffold(
    appBar: AppBar(
      title: const Text("Wi-Fi Provisioning"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          await controller.resetProvisioning();
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(
            ScanScreen.routeName,
          );
        },
      ),
    ),
body: Padding(
  padding: const EdgeInsets.all(12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// STATUS
      Text(
        controller.statusMessage,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      const SizedBox(height: 12),

      /// ---------------- CONNECTING STATE ----------------
      if (controller.state == BleState.provisioning ||
          controller.state == BleState.wifiConnected)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text("Connecting to Wi-Fi..."),
              ],
            ),
          ),
        )

      /// ---------------- WIFI LIST STATE ----------------
      else if (controller.selectedSsid == null)
        controller.wifiList.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text("Scanning nearby Wi-Fi networks..."),
                    ],
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: controller.wifiList.length,
                  itemBuilder: (context, i) {
                    final ssid = controller.wifiList[i];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.wifi),
                        title: Text(ssid),
                        onTap: () {
                          controller.setSelectedSsid(ssid);
                        },
                      ),
                    );
                  },
                ),
              )

      /// ---------------- PASSWORD ENTRY STATE ----------------
      else
        Expanded(
          child: Column(
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.selectedSsid!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              passCtrl.clear();
                              controller.setSelectedSsid(null);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Wi-Fi Password",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (passCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Enter Wi-Fi password"),
                                ),
                              );
                              return;
                            }

                            controller.sendCredentials(
                              controller.selectedSsid!,
                              passCtrl.text,
                            );
                          },
                          child: const Text("Connect"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  ),
),

  );
}

}
