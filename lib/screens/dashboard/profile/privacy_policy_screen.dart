import 'package:flutter/material.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: isDark ? Colors.white : AppColors.textPrimary),
            onPressed: () {
              _showSnackBar(context, '📤 Sharing Privacy Policy...', Colors.blue);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Updated Card
                  _buildLastUpdatedCard(isDark),
                  const SizedBox(height: 20),

                  // Introduction
                  _buildSection(
                    title: '📋 Introduction',
                    content: 'Welcome to SimplyLawgic ("we", "our", "us"). We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our educational platform.',
                    isDark: isDark,
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 16),

                  // Information We Collect
                  _buildSection(
                    title: '1. 📊 Information We Collect',
                    content: 'We collect the following types of information to provide you with the best learning experience:',
                    isDark: isDark,
                    icon: Icons.data_usage,
                    children: [
                      _buildBulletPoint('👤 Personal Data', 'Name, email address, phone number, and educational background.', isDark),
                      _buildBulletPoint('📈 Usage Data', 'Course progress, test scores, watch history, and learning patterns.', isDark),
                      _buildBulletPoint('📱 Device Data', 'IP address, browser type, device information, and cookies.', isDark),
                      _buildBulletPoint('💳 Payment Data', 'Transaction details (processed through secure third-party payment gateways).', isDark),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // How We Use Your Information
                  _buildSection(
                    title: '2. 🎯 How We Use Your Information',
                    content: 'Your information helps us deliver a personalized learning experience:',
                    isDark: isDark,
                    icon: Icons.analytics,
                    children: [
                      _buildBulletPoint('📚 Provide Services', 'Deliver and improve our educational services.', isDark),
                      _buildBulletPoint('📊 Track Progress', 'Monitor your learning progress and achievements.', isDark),
                      _buildBulletPoint('🎨 Personalize', 'Customize your learning experience based on your preferences.', isDark),
                      _buildBulletPoint('🔔 Notifications', 'Send important updates about courses and features.', isDark),
                      _buildBulletPoint('💳 Payments', 'Process payments and manage subscriptions securely.', isDark),
                      _buildBulletPoint('📈 Analytics', 'Analyze usage patterns to enhance our platform.', isDark),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Data Protection
                  _buildSection(
                    title: '3. 🔒 Data Protection',
                    content: 'We implement appropriate technical and organizational security measures to protect your personal data from unauthorized access, alteration, disclosure, or destruction. All data is encrypted using industry-standard protocols.',
                    isDark: isDark,
                    icon: Icons.security,
                  ),
                  const SizedBox(height: 16),

                  // Your Rights
                  _buildSection(
                    title: '4. ⚖️ Your Rights',
                    content: 'Under data protection laws, you have the following rights:',
                    isDark: isDark,
                    icon: Icons.gavel,
                    children: [
                      _buildBulletPoint('🔍 Access', 'Request access to your personal data.', isDark),
                      _buildBulletPoint('✏️ Correction', 'Correct inaccurate or incomplete data.', isDark),
                      _buildBulletPoint('🗑️ Deletion', 'Delete your data (subject to legal obligations).', isDark),
                      _buildBulletPoint('⏸️ Withdraw', 'Withdraw consent at any time.', isDark),
                      _buildBulletPoint('📤 Portability', 'Request data portability.', isDark),
                      _buildBulletPoint('📢 Complaint', 'Lodge a complaint with a supervisory authority.', isDark),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cookies
                  _buildSection(
                    title: '5. 🍪 Cookies and Tracking',
                    content: 'We use cookies and similar tracking technologies to enhance your browsing experience, analyze traffic, and personalize content. You can manage cookie preferences through your browser settings.',
                    isDark: isDark,
                    icon: Icons.cookie,
                  ),
                  const SizedBox(height: 16),

                  // Third-Party Services
                  _buildSection(
                    title: '6. 🤝 Third-Party Services',
                    content: 'We may share your data with trusted third-party service providers to help us operate the platform, process payments, and analyze usage. These parties are bound by confidentiality agreements and data protection laws.',
                    isDark: isDark,
                    icon: Icons.share_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Contact Us
                  _buildSection(
                    title: '7. 📬 Contact Us',
                    content: 'If you have any questions about this Privacy Policy, please contact us:',
                    isDark: isDark,
                    icon: Icons.contact_support,
                    children: [
                      _buildContactItem(Icons.email_rounded, 'Email', 'privacy@simplylawgic.com', isDark),
                      _buildContactItem(Icons.phone_rounded, 'Phone', '+1 234 567 8900', isDark),
                      _buildContactItem(Icons.location_on_rounded, 'Address', '123 Education Street, Learning City, 10001', isDark),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Version
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '📌 Version 2.1.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Sticky Accept Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox
                InkWell(
                  onTap: () {
                    setState(() {
                      _isAccepted = !_isAccepted;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isAccepted ? AppColors.primary : Colors.grey,
                            width: 2,
                          ),
                          color: _isAccepted ? AppColors.primary : Colors.transparent,
                        ),
                        child: _isAccepted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'I accept',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Accept Button
                SizedBox(
                  width: 150,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isAccepted
                        ? () {
                      _showSnackBar(context, '✅ Privacy Policy accepted!', Colors.green);
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isAccepted ? Colors.white : (isDark ? Colors.white60 : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.update_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'August 31, 2026',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
    IconData? icon,
    List<Widget>? children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          if (children != null) ...[
            const SizedBox(height: 10),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}