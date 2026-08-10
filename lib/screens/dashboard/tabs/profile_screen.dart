// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/screens/auth/sign_in_screen.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storage = StorageService();
  Student? _student;
  bool _isLoading = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final student = await _storage.getStudent();
      setState(() => _student = student);
    } catch (e) {
      // Handle error
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadThemePreference() async {
    try {
      final isDark = await _storage.getThemePreference();
      if (mounted) {
        setState(() => _isDarkMode = isDark ?? false);
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  Future<void> _toggleTheme() async {
    final newTheme = !_isDarkMode;
    setState(() => _isDarkMode = newTheme);
    await _storage.saveThemePreference(newTheme);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newTheme ? '🌙' : '☀️'} ${newTheme ? 'Dark' : 'Light'} mode enabled'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout? You\'ll need to sign in again.',
          style: TextStyle(
            color: _isDarkMode ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _isDarkMode ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _storage.clearAll();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
                (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the stored theme preference
    final isDark = _isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF12121A) : Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : AppColors.textSecondary,
              size: 24,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.white : AppColors.primary,
          ),
        ),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header Card
            _ProfileHeaderCard(
              student: _student,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Stats Card
            _StatsCard(
              student: _student,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Theme Toggle Card
            _ThemeToggleCard(
              isDark: isDark,
              onToggle: _toggleTheme,
            ),

            const SizedBox(height: 4),

            // Menu Items
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () => _showComingSoon('Edit Profile'),
                  isDark: isDark,
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showComingSoon('Notifications'),
                  trailing: _NotificationBadge(isDark: isDark),
                  isDark: isDark,
                ),
                _MenuItem(
                  icon: Icons.bookmark_outline,
                  title: 'Saved Items',
                  onTap: () => _showComingSoon('Saved Items'),
                  isDark: isDark,
                ),
                _MenuItem(
                  icon: Icons.history_outlined,
                  title: 'Watch History',
                  onTap: () => _showComingSoon('Watch History'),
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // Support Section
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _showComingSoon('Help & Support'),
                  isDark: isDark,
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _showComingSoon('Privacy Policy'),
                  isDark: isDark,
                ),
                _MenuItem(
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  onTap: () => _showComingSoon('Share'),
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.error.withOpacity(0.08),
                ),
                onPressed: _logout,
                icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
                label: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.3) : AppColors.textSecondary.withOpacity(0.5),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon! 🚀'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _isDarkMode ? const Color(0xFF1A1A2E) : null,
      ),
    );
  }
}

// ============== Theme Toggle Card ==============
class _ThemeToggleCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggleCard({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : AppColors.textPrimary).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? Colors.amber.withOpacity(0.15) : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.amber : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isDark ? 'Currently in dark mode' : 'Switch to dark mode',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

// ============== Profile Header Card ==============
class _ProfileHeaderCard extends StatelessWidget {
  final Student? student;
  final bool isDark;

  const _ProfileHeaderCard({
    required this.student,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = student?.name ?? 'User';
    final email = student?.email ?? 'No email';
    final phone = student?.phone ?? 'No phone';
    final examLabel = student?.preparingForExamLabel ?? 'Student';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF1A1A2E) : AppColors.primary,
            isDark ? const Color(0xFF16213E) : AppColors.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : AppColors.primary).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 4),

          // Email with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Phone with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_outlined, size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Exam Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  examLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Stats Card ==============
class _StatsCard extends StatelessWidget {
  final Student? student;
  final bool isDark;

  const _StatsCard({
    required this.student,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : AppColors.textPrimary).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: '12',
            label: 'Courses',
            icon: Icons.play_circle_outline,
            color: AppColors.primary,
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
          ),
          _StatItem(
            value: '28',
            label: 'Downloads',
            icon: Icons.download_outlined,
            color: const Color(0xFFE53935),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
          ),
          _StatItem(
            value: '4',
            label: 'Tests',
            icon: Icons.assignment_outlined,
            color: const Color(0xFF1E88E5),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white.withOpacity(0.5) : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============== Menu Section ==============
class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  final bool isDark;

  const _MenuSection({
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : AppColors.textPrimary).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _MenuTile(
                  item: item,
                  isDark: isDark,
                ),
                if (index < items.length - 1)
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isDark;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    required this.isDark,
  });
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool isDark;

  const _MenuTile({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              if (item.trailing != null) ...[
                item.trailing!,
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? Colors.white.withOpacity(0.3) : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== Notification Badge ==============
class _NotificationBadge extends StatelessWidget {
  final bool isDark;

  const _NotificationBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '3',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}