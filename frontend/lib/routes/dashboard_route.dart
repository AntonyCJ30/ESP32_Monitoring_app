import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/dashboard_service.dart';
import '../auth/auth_controller.dart';

class DashboardRoute {
  static const routeName = '/dashboard';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => DashboardController(
            DashboardService(),
            context.read<AuthController>(), // from main MultiProvider
          ),
          child: const DashboardScreen(),
        );
      },
    );
  }
}