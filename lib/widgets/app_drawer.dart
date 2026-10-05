// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/screens/purchase/your_purchase_screen.dart';

import 'package:simplylawgic/utils/app_colors.dart';

import '../screens/dashboard/profile/edit_profile_screen.dart';
import '../screens/dashboard/profile/help_support_screen.dart';
import '../screens/dashboard/profile/share_app_screen.dart';
import '../screens/rate/rate_us_screen.dart';

class AppDrawer extends StatelessWidget {
  final Student? student;
  final Function(int index)? onNavigate;
  // NOTE: logout ab EditProfileScreen me hai. Ye param sirf parent ka compile
  // na toote isliye rakha hai (unused).
  final VoidCallback? onLogout;
  final VoidCallback? onProfileUpdated;

  const AppDrawer({
    super.key,
    this.student,
    this.onNavigate,
    this.onLogout,
    this.onProfileUpdated,
  });

  Future<void> _openInBrowser(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const YourPurchaseScreen(),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RateUsScreen(),
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
                      _openInBrowser('https://simplylawgic.com/privacy');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms and Conditions',
                    subtitle: 'Rules and terms of platform usage',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      _openInBrowser('https://simplylawgic.com/terms');
                    },
                  ),
                ],
              ),
            ),
            // 🔹 Refactored Asset Images Footer Section
            _buildSocialFooter(context, secondaryTextColor, borderColor, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
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
            Icon(
              Icons.close_rounded,
              color: textColor.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

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
              builder: (_) => const EditProfileScreen(showBackButton: true),
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
                          color: isDestructive ? AppColors.danger : textColor,
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

  Widget _buildSocialFooter(
      BuildContext context,
      Color secondaryTextColor,
      Color borderColor,
      bool isDark,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Text(
            'Connect With Us',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialAssetButton(
                assetPath: 'assets/images/ws.png',
                tooltip: 'Website',
                onTap: () => _openInBrowser('https://simplylawgic.com'),
                isDark: isDark,
              ),
              _buildSocialAssetButton(
                assetPath: 'assets/images/ig.png',
                tooltip: 'Instagram',
                onTap: () => _openInBrowser('https://instagram.com/simply_lawgicnotes'),
                isDark: isDark,
              ),
              _buildSocialAssetButton(
                assetPath: 'assets/images/yt.png',
                tooltip: 'YouTube',
                onTap: () => _openInBrowser('https://youtube.com/@simplylawgic'),
                isDark: isDark,
              ),
              _buildSocialAssetButton(
                assetPath: 'assets/images/tg.png',
                tooltip: 'Telegram',
                onTap: () => _openInBrowser('https://t.me/simplylawgic'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAssetButton({
    required String assetPath,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A26) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade300,
            ),
          ),
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.link_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}