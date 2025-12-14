import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Setup App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0), // professional blue
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
      ),

      // Route table: keep main.dart responsible only for routing & app-level config
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
      },

      
    );
  }
}
