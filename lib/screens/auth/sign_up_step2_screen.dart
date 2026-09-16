// lib/screens/auth/sign_up_step2_screen.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/utils/validators.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/screens/dashboard/dashboard_screen.dart';
import 'package:simplylawgic/models/student_model.dart';

import '../dashboard/judiciary_exam_constants.dart';


class SignUpStep2Screen extends StatefulWidget {
  final String phone;
  final String phoneVerificationToken;

  const SignUpStep2Screen({
    super.key,
    required this.phone,
    required this.phoneVerificationToken,
  });

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Exam selection state
  String? _selectedExamValue;
  String? _selectedExamLabel;
  String? _examErrorText;

  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _completeSignUp() async {
    final isFormValid = _formKey.currentState!.validate();

    setState(() {
      _examErrorText = _selectedExamValue == null ? 'Please select the exam you are preparing for' : null;
    });

    if (!isFormValid || _selectedExamValue == null) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signupData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'phone': widget.phone,
        'preparingForExam': _selectedExamValue,
        'phoneVerificationToken': widget.phoneVerificationToken,
      };

      final response = await _apiService.signUp(signupData);

      if (mounted) {
        // Check if the response contains token and student
        if (response.containsKey('token') && response.containsKey('student')) {
          final student = Student.fromJson(response['student']);
          final profileComplete = response['profileComplete'] ?? true;

          // Save using the comprehensive method (same as SignInScreen)
          await _storage.saveToken(response['token']);
          await _storage.saveStudent(student);
          await _storage.saveProfileComplete(profileComplete);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Account created successfully!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
          );
        } else {
          // New user sign up (fallback)
          final student = Student.fromJson(response['student']);
          final profileComplete = response['profileComplete'] ?? true;

          await _storage.saveToken(response['token']);
          await _storage.saveStudent(student);
          await _storage.saveProfileComplete(profileComplete);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Account created successfully!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openExamPicker({required bool isDark, required Color textColor, required Color secondaryTextColor, required Color cardColor, required Color borderColor}) {
    if (_isLoading) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12121A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryTextColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          "Select exam",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: secondaryTextColor),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        _ExamSectionHeader(title: "State Judicial Services", color: secondaryTextColor),
                        ...STATE_JUDICIAL_SERVICES.map((e) => _ExamOptionTile(
                          label: e['label']!,
                          selected: _selectedExamValue == e['value'],
                          textColor: textColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          onTap: () {
                            setState(() {
                              _selectedExamValue = e['value'];
                              _selectedExamLabel = e['label'];
                              _examErrorText = null;
                            });
                            Navigator.pop(sheetContext);
                          },
                        )),
                        const SizedBox(height: 16),
                        _ExamSectionHeader(title: "Union Territory Judicial Services", color: secondaryTextColor),
                        ...UNION_TERRITORY_JUDICIAL_SERVICES.map((e) => _ExamOptionTile(
                          label: e['label']!,
                          selected: _selectedExamValue == e['value'],
                          textColor: textColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          onTap: () {
                            setState(() {
                              _selectedExamValue = e['value'];
                              _selectedExamLabel = e['label'];
                              _examErrorText = null;
                            });
                            Navigator.pop(sheetContext);
                          },
                        )),
                        const SizedBox(height: 16),
                        _ExamSectionHeader(title: "Other", color: secondaryTextColor),
                        ...OTHER_JUDICIARY_OPTIONS.map((e) => _ExamOptionTile(
                          label: e['label']!,
                          selected: _selectedExamValue == e['value'],
                          textColor: textColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          onTap: () {
                            setState(() {
                              _selectedExamValue = e['value'];
                              _selectedExamLabel = e['label'];
                              _examErrorText = null;
                            });
                            Navigator.pop(sheetContext);
                          },
                        )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF7F8FA);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppColors.border;
    final appBarColor = isDark ? const Color(0xFF12121A) : Colors.transparent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Create account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Complete your profile to get started",
                  style: TextStyle(color: secondaryTextColor, fontSize: 15),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!, isDark: isDark),
                  const SizedBox(height: 16),
                ],

                // Phone number display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone_outlined, color: secondaryTextColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone number',
                              style: TextStyle(fontSize: 12, color: secondaryTextColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+91 ${widget.phone}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.verified_rounded, color: Colors.green.shade600, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Full name",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondaryTextColor),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: "Enter your full name",
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  "Email",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondaryTextColor),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hint: "you@example.com",
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),

                Text(
                  "Password",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondaryTextColor),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hint: "Create a password",
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  validator: Validators.validatePassword,
                  suffixIcon: IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Confirm password",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondaryTextColor),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: "Re-enter your password",
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Preparing for",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondaryTextColor),
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _openExamPicker(
                    isDark: isDark,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _examErrorText != null ? AppColors.error : borderColor,
                        width: _examErrorText != null ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.gavel_rounded, size: 20, color: secondaryTextColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedExamLabel ?? "Select the exam you're preparing for",
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedExamLabel != null
                                  ? textColor
                                  : secondaryTextColor.withOpacity(0.6),
                              fontWeight: _selectedExamLabel != null ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: secondaryTextColor),
                      ],
                    ),
                  ),
                ),
                if (_examErrorText != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _examErrorText!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isLoading ? null : _completeSignUp,
                    child: _isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                        : const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms and conditions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'By creating an account, you agree to our ',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Terms & Conditions'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardColor,
    required Color borderColor,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      enabled: !_isLoading,
      style: TextStyle(fontSize: 15, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.6), fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: secondaryTextColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6)
        ),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.4)
        ),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.6)
        ),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),
    );
  }
}

class _ExamSectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _ExamSectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3),
      ),
    );
  }
}

class _ExamOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final Color textColor;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ExamOptionTile({
    required this.label,
    required this.selected,
    required this.textColor,
    required this.cardColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.1) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : textColor,
                  ),
                ),
              ),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;

  const _ErrorBanner({
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  height: 1.3
              ),
            ),
          ),
        ],
      ),
    );
  }
}