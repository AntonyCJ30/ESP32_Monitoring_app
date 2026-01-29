import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/token_storage.dart';

import 'login_screen.dart';
import '../routes/dashboard_route.dart';
import '../onboarding/onboarding_screen.dart';

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  bool _navigated = false; // ensures navigation happens once

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _decide();
  }

  Future<void> _decide() async {
    if (_navigated) return;

    final auth = context.watch<AuthController>();

    // 1️⃣ Wait until Firebase auth state is resolved
    if (auth.loading) return;

    _navigated = true;

    // 2️⃣ Not logged in → Login
    if (!auth.loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // 3️⃣ Logged in → check device provisioning
    final deviceToken = await TokenStorage.getDeviceToken();

    if (!mounted) return;

    // 4️⃣ Logged in but no device → Onboarding
    if (deviceToken == null) {
      Navigator.pushReplacementNamed(
        context,
        OnboardingScreen.routeName,
      );
      return;
    }

    // 5️⃣ Logged in + device paired → Dashboard
    Navigator.pushReplacementNamed(
      context,
      DashboardRoute.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen while deciding
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
