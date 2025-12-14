import 'package:flutter/material.dart';
import '../ble/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final BleService ble = BleService();

  final List<ScanResult> scanResults = [];
  bool scanning = false;
  bool connected = false;
  String status = "Idle";

  late TabController tabController;

  final ssidCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    ble.init();
  }

  @override
  void dispose() {
    tabController.dispose();
    ble.disconnect();
    super.dispose();
  }

  void startScan() {
    scanning = true;
    status = "Scanning...";
    setState(() {});

    ble.scan().listen((results) {
      setState(() {
        scanResults
          ..clear()
          ..addAll(results);
      });
    });
  }

  Future<void> connect(BluetoothDevice d) async {
    try {
      FlutterBluePlus.stopScan();
      await ble.connect(d);
      connected = true;
      status = "Connected";

      ble.txStream().listen((msg) {
        setState(() => status = "Notify: $msg");
      });

      tabController.animateTo(1);
    } catch (e) {
      status = "Connection failed";
    }
    setState(() {});
  }

  Future<void> sendCredentials() async {
    await ble.sendJson({"ssid": ssidCtrl.text, "password": passCtrl.text});
    setState(() => status = "Credentials sent");
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("BLE Onboarding"),
      toolbarHeight: 48, // keeps header compact
    ),

    body: Column(
      children: [
        // 👇 TAB BAR SEPARATED FROM APP BAR
        Container(
          color: Colors.white,
          child: TabBar(
            controller: tabController,
            labelColor: const Color(0xFF1565C0),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1565C0),
            tabs: const [
              Tab(icon: Icon(Icons.search), text: "Scan"),
              Tab(icon: Icon(Icons.wifi), text: "Provision"),
            ],
          ),
        ),

        // 👇 TAB CONTENT
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              /// ================= SCAN TAB =================
              Column(
                children: [
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: scanning ? null : startScan,
                    child: const Text("Start BLE Scan"),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: scanResults.length,
                      itemBuilder: (_, i) {
                        final r = scanResults[i];
                        return ListTile(
                          title: Text(
                            r.advertisementData.advName.isNotEmpty
                                ? r.advertisementData.advName
                                : "Unknown Device",
                          ),
                          subtitle: Text(r.device.id.id),
                          trailing: ElevatedButton(
                            onPressed: () => connect(r.device),
                            child: const Text("Connect"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              /// ================= PROVISION TAB =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      connected ? "Connected" : "Not connected",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ssidCtrl,
                      decoration: const InputDecoration(
                        labelText: "Wi-Fi SSID",
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: connected ? sendCredentials : null,
                      child: const Text("Send Credentials"),
                    ),
                    const SizedBox(height: 16),
                    Text("Status: $status"),
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
