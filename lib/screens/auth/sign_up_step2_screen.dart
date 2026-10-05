// lib/screens/auth/sign_up_step2_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // 👇 Naye optional pre-fill params
  final String? initialName;
  final String? initialEmail;
  final String? initialExam;
  final String? initialExamLabel;

  const SignUpStep2Screen({
    super.key,
    required this.phone,
    required this.phoneVerificationToken,
    this.initialName,
    this.initialEmail,
    this.initialExam,
    this.initialExamLabel,
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

  String? _selectedExamValue;
  String? _selectedExamLabel;
  String? _examErrorText;

  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  // 👇 initState mein pre-fill
  @override
  void initState() {
    super.initState();

    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
    if (widget.initialExam != null && widget.initialExam!.isNotEmpty) {
      _selectedExamValue = widget.initialExam;
    }
    if (widget.initialExamLabel != null &&
        widget.initialExamLabel!.isNotEmpty) {
      _selectedExamLabel = widget.initialExamLabel;
    } else if (widget.initialExam != null && widget.initialExam!.isNotEmpty) {
      // Label resolve karne ki koshish karo constants se
      _selectedExamLabel = _resolveExamLabel(widget.initialExam!);
    }
  }

  // 👇 Constants se label nikalne ka helper
  String? _resolveExamLabel(String value) {
    for (final e in STATE_JUDICIAL_SERVICES) {
      if (e['value'] == value) return e['label'];
    }
    for (final e in UNION_TERRITORY_JUDICIAL_SERVICES) {
      if (e['value'] == value) return e['label'];
    }
    for (final e in OTHER_JUDICIARY_OPTIONS) {
      if (e['value'] == value) return e['label'];
    }
    return null;
  }

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
      _examErrorText = _selectedExamValue == null
          ? 'Please select the exam you are preparing for'
          : null;
    });

    if (!isFormValid || _selectedExamValue == null) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
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
        final student = Student.fromJson(response['student']);
        final profileComplete = response['profileComplete'] ?? true;

        await _storage.saveToken(response['token']);
        await _storage.saveStudent(student);
        await _storage.saveProfileComplete(profileComplete);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(response['message'] ?? 'Account created successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openExamPicker({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardColor,
    required Color borderColor,
  }) {
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
                color: isDark ? const Color(0xFF0F111A) : Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryTextColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                    child: Row(
                      children: [
                        Text(
                          "Select exam",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: secondaryTextColor, size: 20),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      children: [
                        _ExamSectionHeader(
                            title: "State Judicial Services",
                            color: secondaryTextColor),
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
                        const SizedBox(height: 14),
                        _ExamSectionHeader(
                            title: "Union Territory Judicial Services",
                            color: secondaryTextColor),
                        ...UNION_TERRITORY_JUDICIAL_SERVICES.map(
                                (e) => _ExamOptionTile(
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
                        const SizedBox(height: 14),
                        _ExamSectionHeader(
                            title: "Other", color: secondaryTextColor),
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
                        const SizedBox(height: 20),
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
    final backgroundColor =
    isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF181A26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor =
    isDark ? Colors.white60 : const Color(0xFF64748B);
    final borderColor =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Top Logo
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Create account 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Complete your profile to get started",
                  style: TextStyle(color: secondaryTextColor, fontSize: 13),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 12),
                ],

                // Verified Phone Container
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          color: secondaryTextColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone number',
                              style: TextStyle(
                                  fontSize: 11, color: secondaryTextColor),
                            ),
                            Text(
                              '+91 ${widget.phone}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFF10B981), size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Name
                _buildInputLabel("Full Name", textColor),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _nameController,
                  hint: "Enter your full name",
                  icon: Icons.person_outline_rounded,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
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
                const SizedBox(height: 14),

                // Email
                _buildInputLabel("Email Address", textColor),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _emailController,
                  hint: "you@example.com",
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 14),

                // Password
                _buildInputLabel("Password", textColor),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _passwordController,
                  hint: "Create a password",
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  validator: Validators.validatePassword,
                  suffixIcon: IconButton(
                    splashRadius: 18,
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: secondaryTextColor,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm Password
                _buildInputLabel("Confirm Password", textColor),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: "Re-enter password",
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
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
                    splashRadius: 18,
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: secondaryTextColor,
                      size: 18,
                    ),
                    onPressed: () => setState(
                            () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 14),

                // Exam Dropdown Trigger
                _buildInputLabel("Preparing For", textColor),
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openExamPicker(
                    isDark: isDark,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _examErrorText != null
                            ? AppColors.error
                            : borderColor,
                        width: _examErrorText != null ? 1.2 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.gavel_rounded,
                            size: 18, color: secondaryTextColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedExamLabel ?? "Select target exam",
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedExamLabel != null
                                  ? textColor
                                  : secondaryTextColor.withOpacity(0.5),
                              fontWeight: _selectedExamLabel != null
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: secondaryTextColor, size: 18),
                      ],
                    ),
                  ),
                ),
                if (_examErrorText != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(_examErrorText!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 11)),
                  ),
                ],

                const SizedBox(height: 20),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _completeSignUp,
                    child: _isLoading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text(
                      "Create Account",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms & Privacy Text Links
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'By creating an account, you agree to our ',
                        style: TextStyle(
                            fontSize: 12, color: secondaryTextColor),
                      ),
                      _LegalLink(
                          label: 'Terms & Conditions',
                          url: 'https://simplylawgic.com/terms'),
                      Text(' and ',
                          style: TextStyle(
                              fontSize: 12, color: secondaryTextColor)),
                      _LegalLink(
                          label: 'Privacy Policy',
                          url: 'https://simplylawgic.com/privacy'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
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
      style: TextStyle(
          fontSize: 14, color: textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: secondaryTextColor.withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: secondaryTextColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: cardColor,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
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
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.3),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.08) : cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.primary : borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : textColor,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final String url;

  const _LegalLink({required this.label, required this.url});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      final launched =
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not open $label'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}