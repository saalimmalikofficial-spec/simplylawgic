// lib/screens/tests/test_series_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simplylawgic/screens/dashboard/tabs/test_attempt_screen.dart';
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

class _TestSeriesDetailScreenState extends State<TestSeriesDetailScreen> {
  TestSeries? _testSeries;
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  // 👇 Website URL
  static const String _websiteUrl = 'https://simplylawgic.com/';

  @override
  void initState() {
    super.initState();
    _loadTestSeriesDetail();
  }

  Future<void> _loadTestSeriesDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final testSeries = await _apiService.getTestSeriesBySlug(widget.slug);
      setState(() {
        _testSeries = testSeries;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getTotalDuration() {
    if (_testSeries == null) return 0;
    return _testSeries!.tests.fold(0, (sum, test) => sum + test.durationMinutes);
  }

  // ============ OPEN WEBSITE (for paid unlock) ============
  Future<void> _openWebsite() async {
    final Uri url = Uri.parse(_websiteUrl);

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // opens in browser
      );

      if (!launched) {
        throw Exception('Could not launch $_websiteUrl');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Could not open website: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============ START TEST ============
  void _startTest(Test test) {
    // Paid series → website pe bhejo
    if (_testSeries!.isPaid) {
      _openWebsite();
      return;
    }

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
      bottomNavigationBar: _testSeries != null
          ? _buildBottomPurchaseBar(
        isDark,
        cardColor,
        borderColor,
        shadowColor,
        textColor,
        secondaryTextColor,
      )
          : null,
    );
  }

  Widget _buildErrorView(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textDark;
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
        // Collapsible App Bar
        SliverAppBar(
          expandedHeight: 240,
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
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 20),
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
                    errorBuilder: (_, __, ___) => _buildHeaderGradient(isDark),
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
                        Colors.black.withOpacity(0.85),
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
                      const SizedBox(height: 8),
                      Text(
                        testSeries.title,
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
                          _buildHeaderBadge(Icons.assignment_outlined,
                              '${testSeries.testCount} Tests'),
                          const SizedBox(width: 16),
                          _buildHeaderBadge(Icons.timer_outlined,
                              '${_getTotalDuration()} mins'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Body Content
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
                      Text(
                        'About This Series',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        testSeries.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                      if (testSeries.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: testSeries.tags.map((tag) {
                            final tagColor = isDark
                                ? Colors.white.withOpacity(0.15)
                                : AppColors.primary.withOpacity(0.08);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
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

                const SizedBox(height: 20),

                // Tests List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Included Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${testSeries.tests.length} Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

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
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
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
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildTestCard({
    required Test test,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color shadowColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final chipColor =
    isDark ? const Color(0xFF12121E) : AppColors.primary.withOpacity(0.1);
    final chipTextColor = isDark ? Colors.white70 : AppColors.primary;
    final warningBg =
    isDark ? const Color(0xFF2D1F0A) : AppColors.warning.withOpacity(0.12);
    final warningText =
    isDark ? const Color(0xFFF59E0B) : AppColors.accentGrey;
    final dangerText = isDark ? const Color(0xFFEF5350) : AppColors.danger;

    return _buildCardContainer(
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${test.order + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _startTest(test),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: isDark ? const Color(0xFF0A0A0F) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (test.instructions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: warningBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: warningText,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      test.instructions,
                      style: TextStyle(fontSize: 11, color: warningText),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (test.negativeMarksPerWrong > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 13,
                  color: dangerText,
                ),
                const SizedBox(width: 4),
                Text(
                  'Negative Marking: -${test.negativeMarksPerWrong} mark per wrong answer',
                  style: TextStyle(fontSize: 11, color: dangerText),
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

  Widget _buildBottomPurchaseBar(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color shadowColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final testSeries = _testSeries!;
    final priceColor = testSeries.isPaid
        ? (isDark ? Colors.white : AppColors.primary)
        : (isDark ? const Color(0xFF4CAF50) : AppColors.secondary);

    final buttonBg = testSeries.isPaid
        ? (isDark ? Colors.white : AppColors.primary)
        : (isDark ? const Color(0xFF4CAF50) : AppColors.secondary);

    final buttonTextColor = testSeries.isPaid
        ? (isDark ? const Color(0xFF0A0A0F) : Colors.white)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(fontSize: 11, color: secondaryTextColor),
                ),
                Text(
                  testSeries.isPaid
                      ? '₹${testSeries.priceAmount} ${testSeries.currency}'
                      : 'FREE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: priceColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBg,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                elevation: 0,
              ),
              onPressed: () {
                if (testSeries.isPaid) {
                  // 👇 Paid → open website
                  _openWebsite();
                } else if (testSeries.tests.isNotEmpty) {
                  _startTest(testSeries.tests.first);
                }
              },
              child: Text(
                testSeries.isPaid ? 'Unlock Now' : 'Start Free Test',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}