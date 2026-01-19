import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard_controller.dart';
import 'dashboard_state.dart';
import '../screens/app_entry_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Trigger initial dashboard load ONCE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final state = controller.state;

    // ───────── Loading ─────────
    if (state.status == DashboardStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ───────── Error ─────────
    if (state.status == DashboardStatus.error) {
      return const Scaffold(
        body: Center(child: Text("Failed to load patient vitals")),
      );
    }

    // ───────── Ready ─────────
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── Patient / Device Header ─────────
            Text(
              state.deviceName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: state.online ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(state.online ? "Online" : "Offline"),
                const Spacer(),
                if (state.criticalAlert)
                  const Chip(
                    label: Text(
                      "CRITICAL",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ───────── Status Card ─────────
            Card(
              child: ListTile(
                title: const Text("Status"),
                subtitle: Text(
                  state.lastUpdated == null
                      ? "No data yet"
                      : "Last updated: ${state.lastUpdated}",
                ),
                trailing: Icon(
                  state.criticalAlert ? Icons.warning : Icons.check_circle,
                  color: state.criticalAlert ? Colors.red : Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ───────── Vitals ─────────
            Text(
              "Vital Signs",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _VitalTile(
                    label: "Heart Rate",
                    value: "${state.heartRate} bpm",
                    icon: Icons.favorite,
                  ),
                  _VitalTile(
                    label: "SpO₂",
                    value: "${state.spo2} %",
                    icon: Icons.bloodtype,
                  ),
                  _VitalTile(
                    label: "Body Temp",
                    value: "${state.bodyTemperature} °C",
                    icon: Icons.thermostat,
                  ),
                  _VitalTile(
                    label: "Respiration",
                    value: "${state.respirationRate} /min",
                    icon: Icons.air,
                  ),
                ],
              ),
            ),

            // ───────── Actions ─────────
            Row(
              children: [
                
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.logout();
                       if (!mounted) return;
                       
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const AppEntryScreen()),
                        (_) => false,
                      );
                    },
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _VitalTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
