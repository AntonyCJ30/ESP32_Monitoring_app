import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/auth_controller.dart';

class DashboardRoute {
  static const routeName = '/dashboard';

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => DashboardController(
          DashboardService(),
          context.read<AuthController>(),
        ),
        child: const DashboardScreen(),
      ),
    );
  }
}
