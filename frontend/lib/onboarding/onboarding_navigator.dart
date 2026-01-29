import 'package:flutter/material.dart';

import 'blescan_screen.dart';
import 'provision_screen.dart';

class OnboardingNavigator extends StatelessWidget {
  const OnboardingNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: ScanScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case ScanScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const ScanScreen(),
            );

          case ProvisionScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const ProvisionScreen(),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const ScanScreen(),
            );
        }
      },
    );
  }
}
