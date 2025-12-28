import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';


  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome — Device Setup Demo',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.bluetooth_searching),
                label: const Text('Start Onboarding'),
                onPressed: () {
                  Navigator.pushNamed(context, '/onboarding');
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.info_outline),
                label: const Text('App Info'),
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Device Setup App',
                    applicationVersion: '0.1.0',
                    children: const [
                      Text('This app will later handle BLE provisioning and cloud integration.')
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
