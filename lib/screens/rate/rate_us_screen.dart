// lib/screens/profile/rate_us_screen.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();

  final List<String> _ratingLabels = [
    'Poor',
    'Below Average',
    'Average',
    'Good',
    'Excellent!'
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitRating() {
    FocusScope.of(context).unfocus();

    // Play Store/App Store redirection logic yahan aayegi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for giving us $_selectedRating stars!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : AppColors.bg;
    final cardColor = isDark ? const Color(0xFF12131C) : Colors.white;
    final borderColor =
    isDark ? const Color(0xFF26293B) : const Color(0xFFEAECF0);
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Rate Simply Lawgic',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Main Illustration Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 52,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Opinion Matters!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rate your experience with Simply Lawgic to help us build a better learning platform for law aspirants.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rating Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = starValue),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            starValue <= _selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Rating Label (e.g., "Excellent!")
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _ratingLabels[_selectedRating - 1],
                      key: ValueKey(_selectedRating),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Detailed Feedback Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Care to share more?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Let us know what feature you loved or what needs improvement.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    style: TextStyle(fontSize: 13, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Type your feedback here... (Optional)',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white38
                            : AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0A0A0F)
                          : const Color(0xFFF8F9FA),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit Rating',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}