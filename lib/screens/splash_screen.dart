// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/screens/auth/sign_in_screen.dart';
import 'package:simplylawgic/screens/dashboard/dashboard_screen.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  final StorageService _storage = StorageService();

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();

    _loadTheme();
    _initAnimations();
    _checkAuthentication();
  }

  // ------------------------------------------------------------
  // LOAD THEME
  // ------------------------------------------------------------

  void _loadTheme() {
    _storage.getThemePreference().then((isDark) {
      if (!mounted) return;

      setState(() {
        _isDarkMode = isDark ?? false;
      });

      if (isDark != null) {
        themeManager.setTheme(isDark);
      }
    }).catchError((e) {
      debugPrint('Error loading theme: $e');
    });
  }

  // ------------------------------------------------------------
  // ANIMATIONS
  // ------------------------------------------------------------

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.45,
          curve: Curves.easeIn,
        ),
      ),
    );

    // Logo enters from slightly above
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.55,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ----------------------------------------------------------
    // BOUNCE ANIMATION
    // ----------------------------------------------------------

    _bounceAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.85,
            end: 1.08,
          ).chain(
            CurveTween(curve: Curves.easeOut),
          ),
          weight: 35,
        ),

        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.08,
            end: 0.94,
          ).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
          weight: 20,
        ),

        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.94,
            end: 1.04,
          ).chain(
            CurveTween(curve: Curves.easeOut),
          ),
          weight: 15,
        ),

        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.04,
            end: 0.98,
          ).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
          weight: 10,
        ),

        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.98,
            end: 1.0,
          ).chain(
            CurveTween(curve: Curves.easeOut),
          ),
          weight: 20,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.15,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    _animationController.forward();
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // AUTHENTICATION
  // ------------------------------------------------------------

  Future<void> _checkAuthentication() async {
    // Splash screen duration
    await Future.delayed(
      const Duration(milliseconds: 2200),
    );

    if (!mounted) return;

    try {
      final String? token = await _storage.getToken();

      final bool isLoggedIn =
          token != null && token.isNotEmpty;

      if (!mounted) return;

      await Future.delayed(
        const Duration(milliseconds: 200),
      );

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Authentication check error: $e',
      );

      if (!mounted) return;

      await Future.delayed(
        const Duration(milliseconds: 200),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isDark = _isDarkMode;

    final Color textColor =
    isDark ? Colors.white : Colors.black;

    final Color subtitleColor =
    isDark ? Colors.white70 : Colors.black54;

    final List<Color> gradientColors = isDark
        ? [
      const Color(0xFF0A0A0F),
      const Color(0xFF1A1A2E),
      const Color(0xFF16213E),
    ]
        : [
      const Color(0xFFFFFFFF),
      const Color(0xFFF8F8F8),
      const Color(0xFFEFEFEF),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? const SystemUiOverlayStyle(
        statusBarIconBrightness:
        Brightness.light,
        statusBarBrightness:
        Brightness.dark,
      )
          : const SystemUiOverlayStyle(
        statusBarIconBrightness:
        Brightness.dark,
        statusBarBrightness:
        Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                // =================================================
                // LOGO
                // =================================================

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _bounceAnimation,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            decoration:
                            BoxDecoration(
                              color: isDark
                                  ? Colors.white
                                  .withOpacity(0.1)
                                  : Colors.grey
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.gavel,
                              size: 60,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // APP NAME
                // =================================================

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Simply Lawgic',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                          FontWeight.w600,
                          color: textColor,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Your Legal Companion',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                          letterSpacing: 0.5,
                          fontWeight:
                          FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // NO LOADER
                // NO DARK MODE BUTTON
                // =================================================
              ],
            ),
          ),
        ),
      ),
    );
  }
}