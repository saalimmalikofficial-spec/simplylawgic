import 'package:flutter/material.dart';
import 'package:simplylawgic/screens/splash_screen.dart';
import 'package:simplylawgic/utils/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Global instance
final ThemeManager themeManager = ThemeManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EdTechApp());
}

class EdTechApp extends StatefulWidget {
  const EdTechApp({super.key});

  @override
  State<EdTechApp> createState() => _EdTechAppState();
}

class _EdTechAppState extends State<EdTechApp> {
  @override
  void initState() {
    super.initState();

    // Load theme first
    themeManager.loadTheme().then((_) {
      if (mounted) setState(() {});
    });

    // ✅ IMPORTANT: Listener add karo taaki toggle par rebuild ho
    themeManager.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {}); // Rebuild when theme changes
    }
  }

  @override
  void dispose() {
    // Remove listener
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simply Lawgic',
      debugShowCheckedModeBanner: false,
      theme: themeManager.lightTheme,
      darkTheme: themeManager.darkTheme,
      themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}