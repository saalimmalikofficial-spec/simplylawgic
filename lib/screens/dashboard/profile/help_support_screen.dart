import 'package:flutter/material.dart';
import 'package:simplylawgic/screens/auth/sign_in_screen.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Account Issues',
    'Payment',
    'Technical',
    'Course Related',
    'Other'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ---------- Delete Account ----------
  Future<void> _onDeleteAccountTap(bool isDark) async {
    final shouldDelete = await _showDeleteAccountDialog(context, isDark);

    if (shouldDelete == true) {
      final storage = StorageService();
      await storage.clearAll();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF12121A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How can we help you?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send us a message or email anytime',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildFaqItem(
              question: 'How do I reset my password?',
              answer: 'Go to Settings > Account > Change Password. Enter your current password and new password.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'How can I access my purchased courses?',
              answer: 'All your courses are available in the "My Courses" section. Tap on any course to start learning.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'What payment methods are accepted?',
              answer: 'We accept Credit/Debit cards, UPI, Net Banking, and digital wallets like Google Pay and PhonePe.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'How do I contact support?',
              answer: 'You can contact us through this form or email us directly at support@simplylawgic.com.',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Direct Email Card
            _buildEmailCard(isDark),

            const SizedBox(height: 24),

            // Contact Form
            Text(
              'Send us a Message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  // Category Dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white24 : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message Field
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Describe your issue in detail...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_messageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please describe your issue'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your message has been sent! We\'ll respond within 24 hours.'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        _messageController.clear();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone — Delete Account
            _buildDeleteAccountCard(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        iconColor: isDark ? Colors.white60 : AppColors.textSecondary,
        collapsedIconColor: isDark ? Colors.white60 : AppColors.textSecondary,
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard(bool isDark) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email support: support@simplylawgic.com'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.email_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct Email Support',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'support@simplylawgic.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Delete Account Card ----------
  Widget _buildDeleteAccountCard(bool isDark) {
    return InkWell(
      onTap: () => _onDeleteAccountTap(isDark),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(isDark ? 0.10 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_forever_outlined,
                color: AppColors.danger,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Permanently remove your account & data',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteAccountDialog(
      BuildContext context,
      bool isDark,
      ) async {
    const List<String> reasons = [
      'I no longer need this account',
      'I created a duplicate account',
      'I am not satisfied with the app',
      'Privacy or security concerns',
      'Too many notifications',
      'I found a better alternative',
      'Other',
    ];

    String selectedReason = reasons.first;
    bool isDeleting = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final api = ApiService();

            Future<void> handleDelete() async {
              setState(() => isDeleting = true);
              try {
                await api.deleteAccount(selectedReason);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext, true);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Your account has been deleted successfully.',
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                setState(() => isDeleting = false);
                if (!dialogContext.mounted) return;

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString().replaceFirst('Exception: ', ''),
                    ),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                      Icons.delete_forever_outlined,
                      color: AppColors.danger,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action is permanent. Your account and all '
                          'associated data will be removed and cannot be '
                          'recovered.\n\nWhy are you deleting your account?',
                      style: TextStyle(
                        color:
                        isDark ? Colors.white70 : AppColors.textSecondary,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...reasons.map(
                          (reason) => RadioListTile<String>(
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: isDeleting
                            ? null
                            : (val) {
                          if (val != null) {
                            setState(() => selectedReason = val);
                          }
                        },
                        title: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white70
                                : AppColors.textPrimary,
                          ),
                        ),
                        activeColor: AppColors.danger,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.pop(dialogContext, false),
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
                  onPressed: isDeleting ? null : handleDelete,
                  child: isDeleting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Delete Account',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}