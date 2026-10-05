// lib/screens/tests/test_series_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/screens/test/test_attempt_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/models/test_series.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class TestSeriesDetailScreen extends StatefulWidget {
  final String slug;

  const TestSeriesDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  State<TestSeriesDetailScreen> createState() => _TestSeriesDetailScreenState();
}

class _TestSeriesDetailScreenState extends State<TestSeriesDetailScreen>
    with WidgetsBindingObserver {
  TestSeries? _testSeries;
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTestSeriesDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔥 App resumed — refreshing test series');
      _loadTestSeriesDetail();
    }
  }

  Future<void> _loadTestSeriesDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final testSeries = await _apiService.getTestSeriesBySlug(widget.slug);
      if (!mounted) return;
      setState(() {
        _testSeries = testSeries;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getTotalDuration() {
    if (_testSeries == null) return 0;
    return _testSeries!.tests
        .fold(0, (sum, test) => sum + test.durationMinutes);
  }

  String _capitalizeTitle(String title) {
    return title.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.length >= 2 &&
          word == word.toUpperCase() &&
          RegExp(r'^[A-Z]+$').hasMatch(word)) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ============================================================
  // OPEN CHECKOUT
  // ============================================================
  Future<void> _openCheckout() async {
    HapticFeedback.lightImpact();

    final referralCode = await _showReferralCodeSheet();
    if (referralCode == null) {
      debugPrint('❌ User cancelled checkout');
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final response = await _apiService.createCheckoutSession(
        type: 'test-series',
        slug: widget.slug,
        referralCode: referralCode.isEmpty ? null : referralCode,
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      final checkoutUrl = response['checkoutUrl'] as String?;
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('Invalid checkout URL received');
      }

      final uri = Uri.parse(checkoutUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch payment page');
      }

      if (mounted) {
        final amount = response['amount'] ?? '';
        final currency = response['currency'] ?? 'INR';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Complete payment of ₹$amount $currency in browser. '
                  'Come back after payment.',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ============================================================
  // REFERRAL CODE BOTTOM SHEET
  // ============================================================
  Future<String?> _showReferralCodeSheet() async {
    final TextEditingController controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161622) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                      isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Have a Referral Code?',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Apply it to get discount (optional)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white60
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: false,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. SAVE20',
                    hintStyle: TextStyle(
                      letterSpacing: 1,
                      fontWeight: FontWeight.normal,
                      color:
                      isDark ? Colors.white38 : AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                    prefixIcon: Icon(
                      Icons.confirmation_number_outlined,
                      size: 20,
                      color:
                      isDark ? Colors.white54 : AppColors.textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(sheetContext, '');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: isDark
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            final code = controller.text.trim();
                            Navigator.pop(
                              sheetContext,
                              code.isEmpty ? '' : code,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_open_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Apply & Continue',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔥 START TEST — CORRECTED LOGIC
  // ============================================================
  void _startTest(Test test) {
    final series = _testSeries!;

    // 🔥 Series ka helper use karo — ye 3 rules handle karta hai:
    // 1. Series purchased → sab accessible
    // 2. Test free → accessible
    // 3. Test individually unlocked → accessible
    final accessible = series.isTestAccessible(test);

    if (accessible) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestAttemptScreen(
            seriesSlug: widget.slug,
            testId: test.id,
            testTitle: test.title,
          ),
        ),
      );
      return;
    }

    // Locked → checkout
    _openCheckout();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : AppColors.bg;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : AppColors.background;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;
    final shadowColor =
    isDark ? Colors.white.withOpacity(0.03) : AppColors.cardShadow;
    final appBarBg = isDark ? const Color(0xFF12121E) : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.white : AppColors.primary,
        ),
      )
          : _errorMessage != null
          ? _buildErrorView(isDark)
          : _buildContent(
        isDark,
        cardColor,
        borderColor,
        textColor,
        secondaryTextColor,
        shadowColor,
        appBarBg,
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D1B1B)
                    : AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: isDark ? const Color(0xFFEF5350) : AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTestSeriesDetail,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.primary,
                foregroundColor:
                isDark ? const Color(0xFF0A0A0F) : Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      Color shadowColor,
      Color appBarBg,
      ) {
    final testSeries = _testSeries!;

    return CustomScrollView(
      slivers: [
        // ============ COLLAPSIBLE APP BAR ============
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          elevation: 0,
          backgroundColor: appBarBg,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.3),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (testSeries.coverImageUrl.isNotEmpty)
                  Image.network(
                    testSeries.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildHeaderGradient(isDark),
                  )
                else
                  _buildHeaderGradient(isDark),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Category chip + FREE badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              testSeries.subjectCategory.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          if (testSeries.hasFreeTest) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'FREE TEST',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _capitalizeTitle(testSeries.title),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildHeaderBadge(
                            Icons.assignment_outlined,
                            '${testSeries.testCount} Tests',
                          ),
                          const SizedBox(width: 16),
                          _buildHeaderBadge(
                            Icons.timer_outlined,
                            '${_getTotalDuration()} mins',
                          ),
                          // 🔥 Unlocked badge — sirf tab jab SERIES purchased ho
                          if (testSeries.isSeriesPurchased &&
                              testSeries.isPaid) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      size: 13, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Unlocked',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ============ BODY CONTENT ============
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About Section
                _buildCardContainer(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  shadowColor: shadowColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'About This Series',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        testSeries.description.isEmpty
                            ? 'No description available for this series.'
                            : testSeries.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                      if (testSeries.tags.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: testSeries.tags.map((tag) {
                            final tagColor = isDark
                                ? Colors.white.withOpacity(0.15)
                                : AppColors.primary.withOpacity(0.08);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tagColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tests List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.list_alt_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Included Tests',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${testSeries.tests.length} Total',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tests Items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: testSeries.tests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildTestCard(
                      test: testSeries.tests[index],
                      isDark: isDark,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      shadowColor: shadowColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderGradient(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF0A0A0F)]
              : [AppColors.primaryDark, AppColors.primary],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color shadowColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // 🔥 TEST CARD — CORRECTED
  // ============================================================
  Widget _buildTestCard({
    required Test test,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color shadowColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final warningBg =
    isDark ? const Color(0xFF2D1F0A) : AppColors.warning.withOpacity(0.12);
    final warningText =
    isDark ? const Color(0xFFF59E0B) : AppColors.accentGrey;
    final dangerText = isDark ? const Color(0xFFEF5350) : AppColors.danger;

    final series = _testSeries!;

    // 🔥 CORRECT ACCESS CHECK — series ka helper use karo
    final accessible = series.isTestAccessible(test);
    final isLocked = !accessible;

    // 🔥 Free test indicator (sirf tab jab series paid ho)
    final isFreeTest = test.isFree && series.isPaid;
    final isSeriesUnlocked = series.isSeriesPurchased;

    return _buildCardContainer(
      isDark: isDark,
      cardColor: cardColor,
      borderColor: borderColor,
      shadowColor: shadowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Test number badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isLocked
                        ? [
                      AppColors.textMuted.withOpacity(0.6),
                      AppColors.textMuted.withOpacity(0.4),
                    ]
                        : (isFreeTest
                        ? [
                      const Color(0xFF10B981),
                      const Color(0xFF059669),
                    ]
                        : [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ]),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isLocked
                      ? const Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                      : Text(
                    '${test.order + 1}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _capitalizeTitle(test.title),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isLocked
                                  ? textColor.withOpacity(0.6)
                                  : textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 🔥 FREE badge for free tests (in paid series)
                        if (isFreeTest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        // 🔥 Unlocked badge for paid tests (in purchased series)
                        if (!isFreeTest && isSeriesUnlocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF3B82F6),
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'UNLOCKED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTestMeta(
                            Icons.help_outline_rounded,
                            '${test.questionCount} Qs',
                            isDark,
                          ),
                          _buildDotDivider(isDark),
                          _buildTestMeta(
                            Icons.timer_outlined,
                            '${test.durationMinutes} mins',
                            isDark,
                          ),
                          _buildDotDivider(isDark),
                          _buildTestMeta(
                            Icons.workspace_premium_outlined,
                            '${test.totalMarks} Marks',
                            isDark,
                          ),
                          _buildDotDivider(isDark),
                          _buildTestMeta(
                            Icons.trending_up_rounded,
                            test.displayMarksInfo,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ============ START / UNLOCK BUTTON ============
              ElevatedButton(
                onPressed: () => _startTest(test),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLocked
                      ? (isDark
                      ? const Color(0xFF2D2D3D)
                      : const Color(0xFFF1F5F9))
                      : (isDark ? Colors.white : AppColors.primary),
                  foregroundColor: isLocked
                      ? (isDark ? Colors.white70 : AppColors.textMuted)
                      : (isDark ? const Color(0xFF0A0A0F) : Colors.white),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLocked
                          ? Icons.lock_rounded
                          : Icons.play_arrow_rounded,
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isLocked ? 'Unlock' : 'Start',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Instructions box
          if (test.instructions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: warningBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: warningText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      test.instructions,
                      style: TextStyle(
                        fontSize: 11,
                        color: warningText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Negative marking
          if (test.negativeMarksPerWrong > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 13,
                  color: dangerText,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Negative Marking: -${test.negativeMarksPerWrong} mark per wrong answer',
                    style: TextStyle(fontSize: 11, color: dangerText),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestMeta(IconData icon, String text, bool isDark) {
    final color = isDark ? Colors.white38 : AppColors.textMuted;
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }

  Widget _buildDotDivider(bool isDark) {
    final color = isDark ? Colors.white38 : AppColors.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('•', style: TextStyle(color: color, fontSize: 10)),
    );
  }
}