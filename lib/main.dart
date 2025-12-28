import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_service.dart';

import 'screens/app_entry_screen.dart';
import 'screens/home_screen.dart';
import 'routes/onboarding_screen_routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(AuthService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Setup App',
      debugShowCheckedModeBanner: false,

      // ✅ GLOBAL APP STYLES (UNCHANGED)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // ✅ AUTH-AWARE ENTRY POINT
      home: const AppEntryScreen(),

      // ✅ KEEP YOUR EXISTING ROUTES
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        OnboardingRoute.routeName: (context) => const OnboardingRoute(),
      },
    );
  }
}
