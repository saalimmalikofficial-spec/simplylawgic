// lib/screens/dashboard/dashboard_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/main.dart';

import 'package:simplylawgic/screens/dashboard/profile/edit_profile_screen.dart';
import 'package:simplylawgic/screens/auth/sign_in_screen.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/services/student_notifier.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/widgets/app_drawer.dart';

import '../user_progress_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/batches_tab.dart';
import 'tabs/tests_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // CURRENT TAB
  // ============================================================

  int _currentIndex = 0;

  Student? _student;

  final StorageService _storage = StorageService();
  final ApiService _apiService = ApiService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ============================================================
  // TAB NAVIGATORS
  // ============================================================

  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  // ============================================================
  // TAB HISTORY
  // ============================================================

  final List<int> _tabHistory = [0];

  // ============================================================
  // BACK BUTTON
  // ============================================================

  DateTime? _lastBackPress;

  // ============================================================
  // NAVIGATION ITEMS
  // ============================================================

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItemData(
      icon: Icons.play_lesson_outlined,
      activeIcon: Icons.play_lesson_rounded,
      label: 'Batches',
    ),
    _NavItemData(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItemData(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Tests',
    ),
    _NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    StudentNotifier.instance.student.addListener(_onStudentChanged);

    _navigatorKeys = List.generate(
      _navItems.length,
          (_) => GlobalKey<NavigatorState>(),
    );

    _loadUserData();
  }

  // ============================================================
  // STUDENT UPDATE
  // ============================================================

  void _onStudentChanged() {
    if (!mounted) return;

    final updated = StudentNotifier.instance.student.value;

    if (updated != null) {
      setState(() {
        _student = updated;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    StudentNotifier.instance.student.removeListener(_onStudentChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ============================================================
  // PLATFORM BRIGHTNESS
  // ============================================================

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // TAB SWITCH
  // ============================================================

  void _switchTab(int index) {
    if (index < 0 || index >= _navItems.length) {
      return;
    }

    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
      _tabHistory.remove(index);
      _tabHistory.add(index);
    });
  }

  // ============================================================
  // TAB NAVIGATOR
  // ============================================================

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        Widget page;

        switch (index) {
          case 0:
            page = HomeTab(
              scaffoldKey: _scaffoldKey,
            );
            break;
          case 1:
            page = const BatchesTab();
            break;
          case 2:
            page = const UserProgressScreen();
            break;
          case 3:
            page = const TestsTab();
            break;
          case 4:
            page = const EditProfileScreen();
            break;
          default:
            page = HomeTab(
              scaffoldKey: _scaffoldKey,
            );
        }

        return MaterialPageRoute(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }

  // ============================================================
  // BACK BUTTON HANDLER
  // ============================================================

  Future<bool> _handleBackPress() async {
    final currentNavigator = _navigatorKeys[_currentIndex].currentState;

    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    if (_tabHistory.length > 1) {
      setState(() {
        _tabHistory.removeLast();
        _currentIndex = _tabHistory.last;
      });
      return false;
    }

    final now = DateTime.now();

    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      _showExitSnackBar();
      return false;
    }

    await _minimizeApp();
    return false;
  }

  // ============================================================
  // EXIT SNACKBAR
  // ============================================================

  void _showExitSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Press back again to exit',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ============================================================
  // MINIMIZE APP
  // ============================================================

  Future<void> _minimizeApp() async {
    try {
      if (Platform.isAndroid) {
        await SystemNavigator.pop();
      } else if (Platform.isIOS) {
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    } catch (e) {
      debugPrint('Minimize error: $e');
    }
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  Future<void> _loadUserData() async {
    try {
      final local = await _storage.getStudent();

      if (mounted && local != null) {
        setState(() {
          _student = local;
        });
        StudentNotifier.instance.update(local);
      }

      final data = await _apiService.getStudentAnalytics(limit: 20);
      final profileJson = data['profile'];

      if (profileJson is Map<String, dynamic>) {
        final student = Student.fromJson(profileJson);
        await _storage.saveStudent(student);

        if (mounted) {
          setState(() {
            _student = student;
          });
          StudentNotifier.instance.update(student);
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  Future<void> _handleLogout() async {
    try {
      // 1. Clear all local storage (token, student, theme)
      await _storage.clearAll();

      if (!mounted) return;

      // 🔥🔥🔥 RESET THEME TO LIGHT MODE
      await themeManager.setTheme(false);

      // 2. Clear all tab navigators
      for (final key in _navigatorKeys) {
        final navigator = key.currentState;
        if (navigator != null) {
          navigator.popUntil((route) => route.isFirst);
        }
      }

      // 3. Reset tab history
      _tabHistory
        ..clear()
        ..add(0);

      _currentIndex = 0;

      // 4. Navigate to SignIn
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
    isDark ? const Color(0xFF0A0A0F) : AppColors.background;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        drawer: ValueListenableBuilder<Student?>(
          valueListenable: StudentNotifier.instance.student,
          builder: (context, student, _) {
            return AppDrawer(
              student: student,
              onNavigate: (index) {
                if (_scaffoldKey.currentState?.isDrawerOpen == true) {
                  Navigator.of(context).pop();
                }
                _switchTab(index);
              },
              onProfileUpdated: () {
                _loadUserData();
              },
              onLogout: _handleLogout,
            );
          },
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          )
              : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: List.generate(
                _navItems.length,
                    (index) => _buildTabNavigator(index),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildPremiumBottomNav(isDark),
      ),
    );
  }

  // ============================================================
  // OVERLAY BOTTOM NAV BAR WITH SOLID WHITE BUMP
  // ============================================================

  Widget _buildPremiumBottomNav(bool isDark) {
    final navBarColor = isDark ? const Color(0xFF12121A) : Colors.white;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Background Clipper + Solid White Shadow Painter
        CustomPaint(
          painter: _NavBumpShadowPainter(
            color: navBarColor,
            isDark: isDark,
          ),
          child: ClipPath(
            clipper: _NavBumpClipper(),
            child: Container(
              height: 64 + MediaQuery.of(context).padding.bottom,
              color: navBarColor,
            ),
          ),
        ),

        // Nav Items Row
        SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                _navItems.length,
                    (index) {
                  final item = _navItems[index];
                  final isSelected = _currentIndex == index;

                  if (index == 2) {
                    return _buildLogoNavItem(
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () {
                        _switchTab(index);
                      },
                    );
                  }

                  return _buildPremiumNavItem(
                    item: item,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      _switchTab(index);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGO NAV ITEM
  // ============================================================

  Widget _buildLogoNavItem({
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeColor = AppColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(
                          alpha: isDark ? 0.35 : 0.18),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.5)
                          : const Color(0xFFE2E2E8),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_transparent.png',
                      height: 23,
                      width: 23,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -6),
              child: Text(
                '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? activeColor
                      : (isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAV ITEM
  // ============================================================

  Widget _buildPremiumNavItem({
    required _NavItemData item,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeColor = AppColors.primary;

    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: activeColor.withValues(alpha: 0.08),
          highlightColor: activeColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? activeColor : inactiveColor,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CUSTOM CLIPPER FOR TOP CENTER BUMP
// ================================================================

class _NavBumpClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const cornerRadius = 24.0;
    const bumpWidth = 76.0;
    const bumpHeight = 18.0;

    final centerX = size.width / 2;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.lineTo(centerX - bumpWidth / 2 - 10, 0);

    path.cubicTo(
      centerX - bumpWidth / 2 + 8,
      0,
      centerX - bumpWidth / 4,
      -bumpHeight,
      centerX,
      -bumpHeight,
    );
    path.cubicTo(
      centerX + bumpWidth / 4,
      -bumpHeight,
      centerX + bumpWidth / 2 - 8,
      0,
      centerX + bumpWidth / 2 + 10,
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ================================================================
// CUSTOM PAINTER FOR SOLID WHITE BUMP & SUBTLE SHADOW
// ================================================================

class _NavBumpShadowPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _NavBumpShadowPainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _NavBumpClipper().getClip(size);

    // Subtle drop shadow under curved white bar
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Solid Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================================================================
// NAV ITEM DATA
// ================================================================

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}