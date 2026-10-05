// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:simplylawgic/screens/auth/google_auth_service.dart';
import 'package:simplylawgic/screens/splash_screen.dart';
import 'package:simplylawgic/utils/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Global theme manager
final ThemeManager themeManager = ThemeManager();

// 🔥 Global navigator key (Snackbar aur navigation ke liye)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🔥 Global deep link stream (screens isko listen kar sakti hain)
final ValueNotifier<String?> deepLinkStatus = ValueNotifier(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 👇 Google Sign-In init
  print('APP: Initializing Google Sign-In...');
  await GoogleAuthService.instance.initialize();
  print('APP: Google Sign-In initialized');

  runApp(const EdTechApp());
}

class EdTechApp extends StatefulWidget {
  const EdTechApp({super.key});

  @override
  State<EdTechApp> createState() => _EdTechAppState();
}

class _EdTechAppState extends State<EdTechApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    themeManager.loadTheme().then((_) {
      if (mounted) setState(() {});
    });

    themeManager.addListener(_onThemeChanged);

    // 🔥 Deep link init
    _initDeepLinks();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  // ============================================================
  // 🔥 DEEP LINK HANDLING
  // ============================================================
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Case 1: App band thi, deep link click kiya
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔥 Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('🔥 Initial link error: $e');
    }

    // Case 2: App chalu thi (background me), deep link aayi
    _linkSubscription = _appLinks.uriLinkStream.listen(
          (uri) {
        debugPrint('🔥 Deep link stream: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('🔥 Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('🔥 ============================================');
    debugPrint('🔥 DEEP LINK RECEIVED');
    debugPrint('🔥 Full URI: $uri');
    debugPrint('🔥 Scheme: ${uri.scheme}');
    debugPrint('🔥 Host: ${uri.host}');
    debugPrint('🔥 Path: ${uri.path}');
    debugPrint('🔥 Query: ${uri.queryParameters}');
    debugPrint('🔥 ============================================');

    // simplylawgic://purchase?status=success&sid=...
    if (uri.scheme == 'simplylawgic' && uri.host == 'purchase') {
      final status = uri.queryParameters['status'];
      final sid = uri.queryParameters['sid'];

      debugPrint('🔥 Purchase status: $status');
      debugPrint('🔥 SID: $sid');

      // 🔥 ValueNotifier update karo — screens listen karengi
      deepLinkStatus.value = status;

      if (status == 'success') {
        _showPaymentSuccess();
      } else if (status == 'cancel' || status == 'cancelled') {
        _showPaymentCancelled();
      }
    }
  }

  void _showPaymentSuccess() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '✅ Payment successful! Content unlocked.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showPaymentCancelled() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '❌ Payment cancelled',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simply Lawgic',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // 🔥 Ye zaroori hai
      theme: themeManager.lightTheme,
      darkTheme: themeManager.darkTheme,
      themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}