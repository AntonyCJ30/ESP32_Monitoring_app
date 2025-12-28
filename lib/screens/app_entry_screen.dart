import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  @override
  void initState() {
    super.initState();
    // auto-login check on app start
    context.read<AuthController>().checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // Loading / splash state
    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Auth-based navigation
    return auth.loggedIn
        ? const HomeScreen()
        :  LoginScreen();
  }
}
