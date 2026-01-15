import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ble/ble_controller.dart';
import '../ble/ble_state.dart';
import '../screens/dashboard_screen.dart';
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
  Widget build(BuildContext context) {
    final controller = context.watch<BleController>();

    debugPrint(
      "BUILD → state=${controller.state}, "
      "prov=${controller.provisioning}, "
      "token=${controller.deviceToken}",
    );

    // ✅ SINGLE place that reacts to TOKEN
    if (controller.state == BleState.provisioned && !_navigated) {
      _navigated = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(
          DashboardScreen.routeName,
          (_) => false,
        );
      });
    }

    final bool canSend =
        controller.state == BleState.connected &&
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
            /// Human-readable status
            Text(
              controller.statusMessage,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: ssidCtrl,
              enabled: canSend,
              decoration: const InputDecoration(
                labelText: "Wi-Fi SSID",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: passCtrl,
              enabled: canSend,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Wi-Fi Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSend
                    ? () {
                        if (ssidCtrl.text.isEmpty ||
                            passCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Enter SSID and Password"),
                            ),
                          );
                          return;
                        }

                        controller.sendCredentials(
                          ssidCtrl.text.trim(),
                          passCtrl.text,
                        );
                      }
                    : null,
                child: controller.state == BleState.provisioning
                    ? const CircularProgressIndicator()
                    : const Text("Send Credentials"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
