// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/utils/app_colors.dart';

import '../screens/dashboard/profile/edit_profile_screen.dart';
import '../screens/dashboard/profile/help_support_screen.dart';
import '../screens/dashboard/profile/notifications_screen.dart';
import '../screens/dashboard/profile/privacy_policy_screen.dart';
import '../screens/dashboard/profile/share_app_screen.dart';

class AppDrawer extends StatelessWidget {
  final Student? student;
  final Function(int index)? onNavigate;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileUpdated;

  const AppDrawer({
    super.key,
    this.student,
    this.onNavigate,
    this.onLogout,
    this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    final cardColor = isDark ? const Color(0xFF12121A) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;

    return Drawer(
      backgroundColor: bgColor,
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, textColor),
            const SizedBox(height: 8),
            _buildProfileCard(
              context,
              isDark,
              cardColor,
              borderColor,
              textColor,
              secondaryTextColor,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your Purchase',
                    subtitle: 'Notes, tests, and current affairs you bought',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      _showSnackBar(context, 'Your Purchase coming soon!');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.download_outlined,
                    title: 'Your Download',
                    subtitle: 'PDFs and files available to you',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      if (onNavigate != null) onNavigate!(3);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'Help / Support',
                    subtitle: 'Live chat with Simply Lawgic',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Refer & Earn',
                    subtitle: 'Share your code and invite friends',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShareAppScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.star_border_rounded,
                    title: 'Rate',
                    subtitle: 'Tell us how Simply Lawgic is doing',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      _showSnackBar(context, 'Rate coming soon!');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.share_outlined,
                    title: 'Direct Share',
                    subtitle: 'Share Simply Lawgic with a friend',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShareAppScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'New Notification',
                    subtitle: 'Alerts about your account and study',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    badgeCount: 1,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 8),

                  // 🔥🔥🔥 LOGOUT — FIXED
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out of this device',
                    textColor: AppColors.danger,
                    secondaryTextColor: secondaryTextColor,
                    isDestructive: true,
                    onTap: () async {
                      // 🔥 Confirmation dialog PEHLE (drawer band hone se pehle)
                      final shouldLogout = await _showLogoutDialog(
                        context,
                        isDark,
                      );

                      // 🔥 Agar user ne "Logout" tap kiya
                      if (shouldLogout == true && onLogout != null) {
                        onLogout!();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================
  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.gavel_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simply Lawgic',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Text(
                  'STUDENT PORTAL',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Profile Card
  // ============================================================
  Widget _buildProfileCard(
      BuildContext context,
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final name = student?.name ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final avatarUrl = student?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          Navigator.pop(context);

          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditProfileScreen(),
            ),
          );

          if (updated == true) {
            onProfileUpdated?.call();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: ClipOval(
                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? Image.network(
                    avatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _buildInitialAvatar(initial);
                    },
                    errorBuilder: (_, __, ___) =>
                        _buildInitialAvatar(initial),
                  )
                      : _buildInitialAvatar(initial),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      color: AppColors.primary,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  // ============================================================
  // Menu Item
  // ============================================================
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
    int? badgeCount,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDestructive ? AppColors.danger : textColor,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                          isDestructive ? AppColors.danger : textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔥 LOGOUT CONFIRMATION DIALOG
  // ============================================================
  Future<bool?> _showLogoutDialog(BuildContext context, bool isDark) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout? You\'ll need to sign in again.',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Snackbar helper
  // ============================================================
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}