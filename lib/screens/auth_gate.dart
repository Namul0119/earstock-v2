import 'package:flutter/material.dart';

import '../config/api_service.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() =>
      _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService authService;

  @override
  void initState() {
    super.initState();

    authService = AuthService(
      baseUrl: ApiService.baseUrl,
    );

    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final isValid =
        await authService.validateCurrentSession();

    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff151329),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xff00F5C8),
        ),
      ),
    );
  }
}