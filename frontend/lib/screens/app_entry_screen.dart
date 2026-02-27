import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../services/device_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'signup_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../routes/dashboard_route.dart';

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  Future<bool>? _hasDeviceFuture;
  bool _lastAuthState = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    /// 1️⃣ Show loading while auth restoring
    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// 2️⃣ Not logged in → Signup
    if (!auth.loggedIn) {
      _hasDeviceFuture = null; // reset cache
      _lastAuthState = false;
      return const SignupScreen();
    }

    /// 3️⃣ Logged in → ensure device future exists
    if (_hasDeviceFuture == null || !_lastAuthState) {
      _hasDeviceFuture = DeviceService.hasPairedDevice();
      _lastAuthState = true;
    }

    return FutureBuilder<bool>(
      future: _hasDeviceFuture,
      builder: (context, snapshot) {
        /// Loading device state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// Error safety (VERY important)
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Device check failed")),
          );
        }

        final hasDevice = snapshot.data ?? false;

        /// 4️⃣ Route based on provisioning
        if (!hasDevice) {
          return const OnboardingScreen();
        }

        return Navigator(
  onGenerateRoute: (_) => DashboardRoute.route(),
);
      },
    );
  }
}