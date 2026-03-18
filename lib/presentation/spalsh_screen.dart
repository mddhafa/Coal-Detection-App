import 'dart:async';

import 'package:coalmobile_app/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    Timer(const Duration(seconds: 5), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Logo / Lottie
            Center(
              child: Lottie.asset(
                'assets/animations/spalshfile.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            const Text(
              'Coal Mobile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 6),

            // Accent line
            Container(width: 32, height: 2, color: const Color(0xFF1A1A1A)),

            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Smart Mining Operations',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF888888),
                letterSpacing: 1.2,
              ),
            ),

            const Spacer(flex: 3),

            // Company name
            const Text(
              'By: Muhammad Dhafa',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFAAAAAA),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Version
            const Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFCCCCCC),
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
