import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ble/ble_controller.dart';
import '../ble/ble_service.dart';
import '../screens/onboarding_screen.dart';

class OnboardingRoute extends StatelessWidget {
  static const String routeName = '/onboarding';

  const OnboardingRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BleController(BleService())..init(),
      child: const OnboardingScreen(),
    );
  }
}

