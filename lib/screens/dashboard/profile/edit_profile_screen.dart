// lib/screens/profile/profile_detail_screen.dart
// lib/screens/profile/profile_detail_screen.dart
import 'dart:io';   // ✅ correct
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ... rest of your imports

import 'package:simplylawgic/screens/dashboard/profile/select_name_exam_Screen.dart';
import 'package:simplylawgic/screens/dashboard/profile/update_email_screen.dart';
import 'package:simplylawgic/screens/dashboard/profile/update_phone_screen.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/services/student_notifier.dart';
import 'package:simplylawgic/main.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

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

  Future<void> _onEditName() async {
    final currentName = _student?.name ?? '';
    final TextEditingController controller =
    TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A26)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Edit Full Name',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == currentName) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.updateProfile(
        name: newName,
        preparingForExam: _student?.preparingForExam ?? '',
      );

      Student? updatedStudent;
      if (response['student'] is Map<String, dynamic>) {
        updatedStudent = Student.fromJson(response['student']);
      } else {
        updatedStudent = _student != null
            ? Student(
          id: _student!.id,
          name: newName,
          email: _student!.email,
          phone: _student!.phone,
          preparingForExam: _student!.preparingForExam,
          preparingForExamLabel: _student!.preparingForExamLabel,
          authProvider: _student!.authProvider,
          avatarUrl: _student!.avatarUrl,
          referralCode: _student!.referralCode,
          walletBalance: _student!.walletBalance,
        )
            : null;
      }

      if (updatedStudent != null) {
        await _storage.saveStudent(updatedStudent);
        StudentNotifier.instance.update(updatedStudent);

        if (mounted) {
          setState(() {
            _student = updatedStudent;
            _hasChanges = true;
            _isLoading = false;
          });
        }
      }

      if (mounted) {
        _showSnackBar('✅ Name updated successfully', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(
          '❌ ${e.toString().replaceFirst('Exception: ', '')}',
          Colors.red,
        );
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
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
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

  Future<void> _onEditExam() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SelectExamScreen()),
    );
    if (changed == true) {
      _hasChanges = true;
      await _loadUserData();
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
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
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;
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
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _toggleTheme,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
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
                _buildHeader(isDark),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isUploadingAvatar
                            ? null
                            : _showAvatarSourceSheet,
                        child: _buildProfilePicture(isDark, cardColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _student?.name ?? 'User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          _student?.preparingForExamLabel ??
                              'Aspirant',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
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
                                    ? Colors.black.withOpacity(0.2)
                                    : AppColors.cardShadow,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Full Name',
                                value: _student?.name ?? 'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: _onEditName,
                              ),
                              _buildDivider(borderColor),
                              _buildDetailRow(
                                icon: Icons.mail_outline_rounded,
                                label: 'Email Address',
                                value: _student?.email ?? 'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: _onEditEmail,
                              ),
                              _buildDivider(borderColor),
                              _buildDetailRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone Number',
                                value: _student?.phone ?? 'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                onEdit: _onEditPhone,
                              ),
                              _buildDivider(borderColor),
                              _buildDetailRow(
                                icon: Icons.school_outlined,
                                label: 'Preparing For',
                                value: _student?.preparingForExamLabel ??
                                    'Not set',
                                isDark: isDark,
                                textColor: textColor,
                                secondaryTextColor:
                                secondaryTextColor,
                                isLast: true,
                                onEdit: _onEditExam,
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildHeader(bool isDark) {
    return ClipPath(
      clipper: _HeaderCurveClipper(),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 55),
                child: Text(
                  'Profile Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(bool isDark, Color cardColor) {
    final avatarUrl = _student?.avatarUrl;
    final name = _student?.name ?? 'User';

    return Stack(
      children: [
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: cardColor, width: 3.5),
          ),
          child: ClipOval(
            child: _isUploadingAvatar
                ? Container(
              color: Colors.black45,
              child: const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            )
                : (avatarUrl != null && avatarUrl.isNotEmpty)
                ? Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _buildInitials(name, isDark),
            )
                : _buildInitials(name, isDark),
          ),
        ),
        if (!_isUploadingAvatar)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cardColor, width: 2.5),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(String name, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    bool isLast = false,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
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
                    fontSize: 14.5,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : AppColors.primary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        color: borderColor,
        height: 1,
        thickness: 0.8,
      ),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}