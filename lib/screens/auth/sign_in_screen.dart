// lib/screens/auth/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/screens/auth/google_auth_service.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/services/storage_service.dart';

import 'package:simplylawgic/utils/validators.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/widgets/loading_overlay.dart';
import 'package:simplylawgic/screens/dashboard/dashboard_screen.dart';
import 'package:simplylawgic/screens/auth/sign_up_step1_screen.dart';
import 'package:simplylawgic/screens/auth/forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();
  final GoogleAuthService _googleAuthService = GoogleAuthService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      await _storage.saveToken(response.token);
      await _storage.saveStudent(response.student);
      await _storage.saveProfileComplete(response.profileComplete);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final String? idToken = await _googleAuthService.signInAndGetIdToken();
      if (idToken == null || idToken.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final response = await _apiService.googleSignIn(idToken);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
      );
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF181A26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
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

                  // Header Logo Alignment
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
                    "Welcome back 👋",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sign in to continue your learning journey",
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage != null) ...[
                    _ErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 12),
                  ],

                  // Email Field
                  _buildInputLabel("Email Address", textColor),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _emailController,
                    hint: "name@example.com",
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),

                  const SizedBox(height: 14),

                  // Password Field
                  _buildInputLabel("Password", textColor),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _passwordController,
                    hint: "••••••••",
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    suffixIcon: IconButton(
                      splashRadius: 18,
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: secondaryTextColor,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      ),
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: borderColor, thickness: 1)),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: borderColor, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google.png',
                            height: 18,
                            width: 18,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: secondaryTextColor, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpStep1Screen()),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
      style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: secondaryTextColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}