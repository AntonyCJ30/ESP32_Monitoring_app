import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_service.dart';

import 'screens/app_entry_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'routes/dashboard_route.dart';

void main() {
  runApp(
 MultiProvider(
  providers: [
    Provider<AuthService>(
      create: (_) => AuthService(),
    ),

    ChangeNotifierProvider<AuthController>(
      create: (context) => AuthController(
        context.read<AuthService>(),
      ),
    ),
  ],
  child: const MyApp(),
)

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Setup App',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      // Entry decision screen (auth / onboarding / dashboard)
      home: const AppEntryScreen(),

      // Simple static routes
      routes: {
        "/onboarding": (_) => const OnboardingScreen(),
      },

      // Feature routes with wiring (Dashboard)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case DashboardRoute.routeName:
            return DashboardRoute.route();
          default:
            return null;
        }
      },
    );
  }
}
