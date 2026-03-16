import 'dart:async';

import 'package:coalmobile_app/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    super.initState();
    loadSplash();
  }

  Future<Timer> loadSplash() async {
    return Timer(const Duration(seconds: 3), onDoneLoading);
  }

  onDoneLoading() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: ((context) => const LoginScreen())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/animations/spalshfile.json',
          width: 500,
          height: 500,
        ),
      ),
    );
  }
}
