import 'package:flutter/material.dart';

import '../auth/token_storage.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = "/dashboard";
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Reset / Logout",
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Reset Device"),
                  content: const Text(
                      "This will remove the device from this phone and restart onboarding. Continue?"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text("Reset"),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                // 🔥 delete stored token
                await TokenStorage.deleteDeviceToken();

                // 🔥 go back to onboarding and clear stack
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/onboarding',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: const Center(
        child: Text(
          'Dashboard loaded\n(Device paired successfully)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
