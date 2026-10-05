// lib/screens/auth/sign_up_step1_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/services/storage_service.dart';
import 'package:simplylawgic/utils/validators.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/screens/auth/sign_up_step2_screen.dart';
import 'package:simplylawgic/screens/dashboard/dashboard_screen.dart';
import 'package:simplylawgic/models/student_model.dart';

class SignUpStep1Screen extends StatefulWidget {
  const SignUpStep1Screen({super.key});

  @override
  State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> with CodeAutoFill {
  bool _otpSent = false;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  String? _errorMessage;
  String? _phoneVerificationToken;
  int _otpExpirySeconds = 600;

  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  static const MethodChannel _smsChannel =
  MethodChannel('com.bettlebyte.simplylawgic/sms');

  @override
  void initState() {
    super.initState();
    _setupSmsChannel();
    _printAppSignature();
    _requestSmsPermission();
  }

  void _setupSmsChannel() {
    _smsChannel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        final String message = call.arguments as String;
        _extractOTPFromSms(message);
      }
    });
  }

  void _extractOTPFromSms(String message) {
    final regex = RegExp(r'\b\d{4}\b');
    final matches = regex.allMatches(message);
    if (matches.isNotEmpty) {
      final otp = matches.last.group(0)!;
      if (mounted) {
        for (int i = 0; i < 4 && i < otp.length; i++) {
          _otpControllers[i].text = otp[i];
        }
        setState(() {});
      }
    }
  }

  Future<void> _requestSmsPermission() async {
    final smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted) {
      final result = await Permission.sms.request();
      if (result.isPermanentlyDenied && mounted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('SMS Permission Required'),
        content: const Text(
          'To auto-fill OTP, we need SMS permission. Please enable it from app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _printAppSignature() async {
    try {
      await SmsAutoFill().getAppSignature;
    } catch (_) {}
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length >= 4) {
      final digitsOnly = code!.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 4) {
        final otp = digitsOnly.substring(0, 4);
        for (int i = 0; i < 4; i++) {
          _otpControllers[i].text = otp[i];
        }
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    cancel();
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = "Please accept Terms & Conditions and Privacy Policy to continue.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final smsStatus = await Permission.sms.status;
      if (!smsStatus.isGranted) {
        await Permission.sms.request();
      }

      await SmsAutoFill().listenForCode();
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      final response = await _apiService.sendOTP(cleanPhone);

      if (mounted) {
        setState(() {
          _otpSent = true;
          _otpExpirySeconds = response['expiresInSeconds'] ?? 600;
          _errorMessage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'OTP sent successfully'),
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

  Future<void> _verifyOTP() async {
    String otp = '';
    for (int i = 0; i < 4; i++) {
      final value = _otpControllers[i].text.trim();
      if (value.isEmpty || value.length != 1 || !RegExp(r'^\d$').hasMatch(value)) {
        setState(() => _errorMessage = 'Please enter a valid 4-digit OTP');
        return;
      }
      otp += value;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      final response = await _apiService.verifyOTP(cleanPhone, otp);

      if (mounted) {
        if (response.containsKey('token') && response.containsKey('student')) {
          final student = Student.fromJson(response['student']);
          final profileComplete = response['profileComplete'] ?? false;

          await _storage.saveToken(response['token']);
          await _storage.saveStudent(student);
          await _storage.saveProfileComplete(profileComplete);

          if (profileComplete) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  (route) => false,
            );
          } else {
            final String token = response['token'] ?? '';
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => SignUpStep2Screen(
                  phone: cleanPhone,
                  phoneVerificationToken: token,
                ),
              ),
                  (route) => false,
            );
          }
        } else if (response.containsKey('phoneVerificationToken')) {
          _phoneVerificationToken = response['phoneVerificationToken'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpStep2Screen(
                phone: cleanPhone,
                phoneVerificationToken: _phoneVerificationToken!,
              ),
            ),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
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

                // Top Logo (Same as Login Screen)
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
                  _otpSent ? "Verify Mobile Number" : "Get Started 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _otpSent
                      ? "Enter the 4-digit code sent to +91 ${_phoneController.text.replaceAll(RegExp(r'\D'), '')}"
                      : "Enter your mobile number to get registered",
                  style: TextStyle(color: secondaryTextColor, fontSize: 13),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 12),
                ],

                if (!_otpSent) ...[
                  _buildInputLabel("Phone Number", textColor),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                    validator: Validators.validatePhone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 10,
                    style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "98765 43210",
                      hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.5), fontSize: 13),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "🇮🇳 +91",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              height: 16,
                              width: 1,
                              color: borderColor,
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      counterText: "",
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  // Terms & Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _acceptedTerms,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: BorderSide(color: borderColor, width: 1.5),
                          onChanged: _isLoading
                              ? null
                              : (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                              if (_acceptedTerms) _errorMessage = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text("I agree to the ", style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                            _LegalLink(label: "Terms & Conditions", url: "https://simplylawgic.com/terms"),
                            Text(" & ", style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                            _LegalLink(label: "Privacy Policy", url: "https://simplylawgic.com/privacy"),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Get OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (_isLoading || !_acceptedTerms) ? null : _sendOTP,
                      child: _isLoading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text(
                        "Get OTP",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                          (index) => SizedBox(
                        width: 60,
                        height: 52,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          enabled: !_isLoading,
                          maxLength: 1,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: cardColor,
                            contentPadding: EdgeInsets.zero,
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
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) => _onOTPChanged(value, index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expires in ${_otpExpirySeconds ~/ 60}:${(_otpExpirySeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(color: secondaryTextColor, fontSize: 12),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _isLoading ? null : _sendOTP,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _verifyOTP,
                      child: _isLoading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text(
                        "Verify & Next",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
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
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $label'), behavior: SnackBarBehavior.floating),
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