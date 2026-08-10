import 'package:flutter/material.dart';
import 'package:simplylawgic/screens/splash_screen.dart';
import 'screens/auth/sign_in_screen.dart';

void main() {
  runApp(const EdTechApp());
}

class EdTechApp extends StatelessWidget {
  const EdTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimplyLawgic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          primary: const Color(0xFF6C5CE7),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const SplashScreen(),
    );
  }
}