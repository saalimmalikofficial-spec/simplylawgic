// lib/screens/profile/profile_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:simplylawgic/screens/auth/sign_in_screen.dart';
import 'package:simplylawgic/screens/dashboard/profile/select_name_exam_Screen.dart';
import 'package:simplylawgic/screens/dashboard/profile/update_email_screen.dart';
import 'package:simplylawgic/screens/dashboard/profile/update_phone_screen.dart'; // 👈 ADD

import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/services/student_notifier.dart';
import 'package:simplylawgic/main.dart';

class EditProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const EditProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isUploadingAvatar = false;
  Student? _student;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    themeManager.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      if (themeManager.isDarkMode != isDark) {
        themeManager.setTheme(isDark);
      }
    }
  }

  Future<void> _toggleTheme() async {
    HapticFeedback.selectionClick();
    await themeManager.toggleTheme();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            themeManager.isDarkMode
                ? '🌙 Dark mode enabled'
                : '☀️ Light mode enabled',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor:
          themeManager.isDarkMode ? const Color(0xFF1E1E2E) : null,
        ),
      );
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await _apiService.getStudentAnalytics(limit: 20);
      final profileJson = data['profile'];

      Student? student;
      if (profileJson != null && profileJson is Map<String, dynamic>) {
        student = Student.fromJson(profileJson);
        await _storage.saveStudent(student);
        StudentNotifier.instance.update(student);
      } else {
        student = await _storage.getStudent();
        if (student != null) {
          StudentNotifier.instance.update(student);
        }
      }

      if (!mounted) return;
      setState(() {
        _student = student;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      try {
        final local = await _storage.getStudent();
        if (!mounted) return;
        setState(() {
          _student = local;
          _isLoading = false;
        });
        if (local != null) {
          StudentNotifier.instance.update(local);
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return;

      final file = File(image.path);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > 5) {
        _showSnackBar('⚠️ Image too large. Max 5MB allowed.', Colors.orange);
        return;
      }

      setState(() => _isUploadingAvatar = true);
      final response = await _apiService.uploadAvatar(file);
      if (!mounted) return;
      setState(() {
        _isUploadingAvatar = false;
        _hasChanges = true;
      });

      await _loadUserData();

      _showSnackBar(
        '✅ ${response['message'] ?? 'Photo updated.'}',
        Colors.green,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      _showSnackBar(
        '❌ ${e.toString().replaceFirst('Exception: ', '')}',
        Colors.red,
      );
    }
  }

  void _showAvatarSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161622) : Colors.white,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAvatarOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadAvatar(ImageSource.gallery);
                    },
                  ),
                  _buildAvatarOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadAvatar(ImageSource.camera);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEditEmail() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const UpdateEmailScreen()),
    );
    if (changed == true) {
      _hasChanges = true;
      await _loadUserData();
    }
  }
  Future<void> _onEditExam() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectExamScreen(
          initialName: _student?.name,                          // 👈 name pass
          initialExam: _student?.preparingForExam,              // 👈 exam pass
        ),
      ),
    );
    if (changed == true) {
      _hasChanges = true;
      await _loadUserData();
    }
  }
  // ============================================================
  // 👇 Phone Edit → UpdatePhoneScreen
  // ============================================================
  Future<void> _onEditPhone() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const UpdatePhoneScreen()),
    );
    if (changed == true) {
      _hasChanges = true;
      await _loadUserData();
    }
  }

  // ============================================================
  // Logout
  // ============================================================
  Future<void> _onLogoutTap(bool isDark) async {
    final shouldLogout = await _showLogoutDialog(context, isDark);
    if (shouldLogout != true) return;

    await _storage.clearAll();
    if (!mounted) return;

    // 👇 rootNavigator: true — ye poora stack clear karega, bottom nav bhi gayab
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
    );
  }
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
                color: AppColors.danger.withValues(alpha: 0.15),
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

  Widget _buildLogoutButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => _onLogoutTap(isDark),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(
            'Logout',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            backgroundColor:
            AppColors.danger.withValues(alpha: isDark ? 0.10 : 0.05),
            side: BorderSide(
              color: AppColors.danger.withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
        Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
    isDark ? const Color(0xFF0D0D14) : AppColors.background;
    final cardColor = isDark ? const Color(0xFF161622) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor =
    isDark ? Colors.white60 : AppColors.textSecondary;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: widget.showBackButton
              ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context, _hasChanges),
          )
              : null,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: GestureDetector(
                onTap: _toggleTheme,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    themeManager.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        )
            : RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCurvedHeader(isDark),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingAvatar
                            ? null
                            : _showAvatarSourceSheet,
                        child:
                        _buildProfilePicture(isDark, cardColor),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _student?.name ?? 'User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Badges Row (Exam & Wallet Chips)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.school_rounded,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _student?.preparingForExamLabel ??
                                      'Aspirant',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons
                                      .account_balance_wallet_rounded,
                                  size: 13,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '₹${_student?.formattedWalletBalance ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black
                                    .withValues(alpha: 0.25)
                                    : AppColors.cardShadow,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 1. Full Name
                              _buildDetailRow(
                                icon: Icons.person_outline_rounded,
                                iconColor: AppColors.primary,
                                label: 'Full Name',
                                value: _student?.name ?? 'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: null,
                              ),
                              _buildDivider(borderColor),

                              // 2. Email
                              _buildDetailRow(
                                icon: Icons.mail_outline_rounded,
                                iconColor: const Color(0xFF10B981),
                                label: 'Email Address',
                                value: _student?.email ?? 'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: _onEditEmail,
                              ),
                              _buildDivider(borderColor),

                              // 3. Phone  👈 ab onEdit lagaya
                              _buildDetailRow(
                                icon: Icons.phone_outlined,
                                iconColor: const Color(0xFF8B5CF6),
                                label: 'Phone Number',
                                value: _student?.phone ?? 'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: _onEditPhone,
                              ),
                              _buildDivider(borderColor),

                              // 4. Preparing For
                              _buildDetailRow(
                                icon: Icons.school_outlined,
                                iconColor: const Color(0xFFF59E0B),
                                label: 'Preparing For',
                                value:
                                _student?.preparingForExamLabel ??
                                    'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: _onEditExam,
                              ),
                              _buildDivider(borderColor),

                              // 5. Wallet Balance
                              _buildDetailRow(
                                icon: Icons
                                    .account_balance_wallet_outlined,
                                iconColor: const Color(0xFF10B981),
                                label: 'Wallet Balance',
                                value:
                                '₹${_student?.formattedWalletBalance ?? 0}',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: null,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Logout
                      const SizedBox(height: 20),
                      _buildLogoutButton(isDark),
                      const SizedBox(height: 30),
                    ],
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
  // Curved Header Component
  // ============================================================
  Widget _buildCurvedHeader(bool isDark) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1E2E), const Color(0xFF11111B)]
                : [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(bool isDark, Color cardColor) {
    return Stack(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cardColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            backgroundImage: _student?.avatarUrl != null
                ? NetworkImage(_student!.avatarUrl!)
                : null,
            child: _student?.avatarUrl == null
                ? Text(
              (_student?.name.isNotEmpty ?? false)
                  ? _student!.name[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                : null,
          ),
        ),
        if (_isUploadingAvatar)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          )
        else
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cardColor, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // 🔥 Smart Detail Row → Empty pe "Add", filled pe "Edit"
  // ============================================================
  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    VoidCallback? onEdit,
    bool isLast = false,
  }) {
    final bool isEmpty = value.trim().isEmpty ||
        value.trim().toLowerCase() == 'not set';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isEmpty
                        ? secondaryTextColor.withValues(alpha: 0.75)
                        : textColor,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                    isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),

          // 👇 Action button
          if (onEdit != null)
            isEmpty
                ? _buildAddButton(onEdit, iconColor)
                : _buildEditIconButton(onEdit, isDark),
        ],
      ),
    );
  }

  // ➕ "Add" pill button
  Widget _buildAddButton(VoidCallback onTap, Color color) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: color, size: 14),
              const SizedBox(width: 3),
              Text(
                'Add',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✏️ Edit icon
  Widget _buildEditIconButton(VoidCallback onTap, bool isDark) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        Icons.edit_outlined,
        color: isDark ? Colors.white60 : Colors.grey.shade600,
        size: 18,
      ),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(
      height: 1,
      thickness: 1,
      color: borderColor,
      indent: 12,
      endIndent: 12,
    );
  }
}

// Custom Clipper for Smooth Curve
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 45);

    var firstControlPoint = Offset(size.width / 2, size.height + 15);
    var firstEndPoint = Offset(size.width, size.height - 45);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}