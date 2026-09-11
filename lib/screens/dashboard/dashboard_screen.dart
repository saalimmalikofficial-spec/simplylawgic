// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/screens/dashboard/tabs/profile_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/batches_tab.dart';
import 'tabs/tests_tab.dart';
import 'tabs/downloads_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Student? _student;
  final StorageService _storage = StorageService();

  // ✅ List of screens corresponding to bottom navigation tabs
  final List<Widget> _tabs = [
    const HomeTab(),
    const BatchesTab(),
    const TestsTab(),
    const DownloadsTab(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Add observer for theme changes
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    // ✅ Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // ✅ Force rebuild when theme changes
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadUserData() async {
    try {
      final student = await _storage.getStudent();
      setState(() {
        _student = student;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.background;
    final appBarColor = isDark ? const Color(0xFF12121A) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final navBarColor = isDark ? const Color(0xFF12121A) : Colors.white;
    final iconColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final activeIconColor = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _student?.name ?? "User",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Row(
              children: [
                Text(
                  _student?.preparingForExamLabel ?? "Goal: Not Set",
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: secondaryTextColor.withOpacity(0.7),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
                ),
              );
            },
            icon: Icon(Icons.notifications_none, color: textColor),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(
              _student?.name.isNotEmpty == true
                  ? _student!.name[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        systemOverlayStyle: isDark
            ? const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        )
            : const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: _tabs[_currentIndex],  // ✅ Now _tabs is defined
      bottomNavigationBar: _buildModernBottomNav(
        isDark: isDark,
        navBarColor: navBarColor,
        textColor: textColor,
        secondaryTextColor: secondaryTextColor,
        iconColor: iconColor,
        activeIconColor: activeIconColor,
      ),
    );
  }

  Widget _buildModernBottomNav({
    required bool isDark,
    required Color navBarColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required Color activeIconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: navBarColor,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : AppColors.textPrimary).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isDark: isDark,
                iconColor: iconColor,
                activeIconColor: activeIconColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.play_lesson_outlined,
                activeIcon: Icons.play_lesson,
                label: 'Batches',
                isDark: isDark,
                iconColor: iconColor,
                activeIconColor: activeIconColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                label: 'Tests',
                isDark: isDark,
                iconColor: iconColor,
                activeIconColor: activeIconColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.download_outlined,
                activeIcon: Icons.download,
                label: 'Downloads',
                isDark: isDark,
                iconColor: iconColor,
                activeIconColor: activeIconColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isDark: isDark,
                iconColor: iconColor,
                activeIconColor: activeIconColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
    required Color iconColor,
    required Color activeIconColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeIconColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? activeIconColor : iconColor,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeIconColor : secondaryTextColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}