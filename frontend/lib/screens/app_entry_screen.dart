import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../services/device_service.dart';
import '../dashboard/dashboard_screen.dart';

import 'signup_screen.dart';
import '../routes/dashboard_route.dart';
import '../onboarding/onboarding_screen.dart';

class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.loggedIn) {
      return const SignupScreen();
    }

    return FutureBuilder<bool>(
      future: DeviceService.hasPairedDevice(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!) {
          return const OnboardingScreen();
        }

      return const DashboardScreen();
      },
    );
  }
}

