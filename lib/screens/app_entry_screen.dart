import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/token_storage.dart';

import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../onboarding/onboarding_screen.dart';

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final auth = context.read<AuthController>();

    // 1. Restore login session
    await auth.checkAutoLogin();

    // 2. Check if device already provisioned
    String? deviceToken;
    if (auth.loggedIn) {
      deviceToken = await TokenStorage.getDeviceToken();
    }

    if (!mounted) return;

    // 3. Navigate exactly once

    // ❌ Not logged in → Login
    // ❌ Not logged in → Login
    if (!auth.loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

// ❌ Logged in but no device paired → BLE Onboarding
    if (deviceToken == null) {
      Navigator.pushReplacementNamed(
        context,
        OnboardingScreen.routeName,
      );
      return;
    }

// ✅ Logged in and device paired → Dashboard
    Navigator.pushReplacementNamed(
      context,
      DashboardScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Splash while deciding
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
