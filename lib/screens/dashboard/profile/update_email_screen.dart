import 'package:flutter/material.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({super.key});

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(email);
  }

  // ============ SEND OTP ============
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      _showSnackBar(context, '⚠️ Enter a valid email address', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.changeEmailSendOtp(email);

      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });

      _showSnackBar(
        context,
        '📩 ${response['message'] ?? 'OTP sent to your registered mobile number.'}',
        Colors.green,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(
        context,
        '❌ ${e.toString().replaceFirst('Exception: ', '')}',
        Colors.red,
      );
    }
  }

  // ============ VERIFY OTP ============
  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length < 4) {
      _showSnackBar(context, '⚠️ Enter valid OTP', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.changeEmailVerify(email, otp);

      setState(() => _isLoading = false);

      _showSnackBar(
        context,
        '✅ ${response['message'] ?? 'Email updated.'}',
        Colors.green,
      );

      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(
        context,
        '❌ ${e.toString().replaceFirst('Exception: ', '')}',
        Colors.red,
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
          'Update Email',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF12121A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(isDark),
            const SizedBox(height: 24),

            _buildLabel('📧 New Email Address', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isOtpSent,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!_isOtpSent)
              _buildPrimaryButton(
                label: 'Send OTP',
                isLoading: _isLoading,
                onPressed: _sendOtp,
              ),

            if (_isOtpSent) ...[
              _buildLabel('🔐 Enter OTP', isDark),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  counterText: '',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: const Text('Change Email'),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPrimaryButton(
                label: 'Verify & Update',
                isLoading: _isLoading,
                onPressed: _verifyOtp,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.alternate_email_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Update your registered email. An OTP will be sent to your registered mobile number to confirm.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
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