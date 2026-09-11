// lib/screens/user_progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/analytics_model.dart';
import '../services/api_service.dart';

class UserProgressScreen extends StatefulWidget {
  const UserProgressScreen({super.key});

  @override
  State<UserProgressScreen> createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen> {
  final ApiService _apiService = ApiService();
  AnalyticsData? _analyticsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getStudentAnalytics(limit: 50);
      if (mounted) {
        setState(() {
          _analyticsData = AnalyticsData.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dark theme colors
    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final shadowColor = isDark ? Colors.white.withOpacity(0.03) : const Color(0x0A000000);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        // ✅ BACK BUTTON ADDED
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Text(
          'My Progress',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: textColor,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF12121E) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: secondaryTextColor),
            onPressed: _fetchAnalytics,
            tooltip: 'Refresh',
          ),
        ],
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : const Color(0xFF2563EB),
            ),
          ),
        )
            : _errorMessage != null
            ? _buildErrorWidget(isDark)
            : _analyticsData == null
            ? _buildEmptyState(isDark)
            : RefreshIndicator(
          onRefresh: _fetchAnalytics,
          color: isDark ? Colors.white : const Color(0xFF2563EB),
          child: _buildContent(theme, isDark, cardColor, borderColor, textColor, secondaryTextColor, shadowColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Analytics Data Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF2F2);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final errorTextColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D1B1B) : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: isDark ? const Color(0xFFEF5350) : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: errorTextColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAnalytics,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF2563EB),
                foregroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ThemeData theme,
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      Color shadowColor,
      ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(isDark, cardColor, borderColor, shadowColor, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          _buildQuestionBreakdown(isDark, cardColor, borderColor, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          _buildScoreTrend(isDark, cardColor, borderColor, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          if (_analyticsData!.insights.isNotEmpty) ...[
            _buildInsights(isDark),
            const SizedBox(height: 20),
          ],
          _buildCategoryPerformance(isDark, cardColor, borderColor, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          if (_analyticsData!.retakeProgress.isNotEmpty) ...[
            _buildRetakeProgress(isDark, cardColor, borderColor, textColor, secondaryTextColor),
            const SizedBox(height: 20),
          ],
          _buildRecentAttempts(isDark, cardColor, borderColor, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          _buildSeriesPerformance(isDark, cardColor, borderColor, textColor, secondaryTextColor),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color shadowColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final summary = _analyticsData!.summary;
    final items = [
      _SummaryItem('Tests Taken', '${summary.submittedAttemptsCount}', Icons.assignment_turned_in_outlined, const Color(0xFF2563EB)),
      _SummaryItem('Accuracy', '${summary.accuracy.toStringAsFixed(1)}%', Icons.pie_chart_outline, const Color(0xFF10B981)),
      _SummaryItem('Best Score', '${summary.bestPercentage.toStringAsFixed(1)}%', Icons.military_tech_outlined, const Color(0xFFF59E0B)),
      _SummaryItem('Study Streak', '${summary.studyStreakDays} days', Icons.local_fire_department_outlined, const Color(0xFFEF4444)),
      _SummaryItem('This Week', '${summary.testsThisWeek} tests', Icons.calendar_today_outlined, const Color(0xFF8B5CF6)),
      _SummaryItem('This Month', '${summary.testsThisMonth} tests', Icons.calendar_month_outlined, const Color(0xFF0D9488)),
      _SummaryItem('Avg Time Used', '${summary.averageTimeUsedPercent.toStringAsFixed(1)}%', Icons.timer_outlined, const Color(0xFFF97316)),
      _SummaryItem('Bookmarks', '${summary.bookmarkCount}', Icons.bookmark_outline, const Color(0xFF6366F1)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final cardWidth = (MediaQuery.of(context).size.width - 44) / 2;
        return SizedBox(
          width: cardWidth,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 20, color: item.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionBreakdown(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final breakdown = _analyticsData!.questionBreakdown;
    final double correctRatio = breakdown.total > 0 ? breakdown.correct / breakdown.total : 0;
    final double wrongRatio = breakdown.total > 0 ? breakdown.wrong / breakdown.total : 0;
    final double skippedRatio = breakdown.total > 0 ? breakdown.skipped / breakdown.total : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              Text(
                'Total: ${breakdown.total}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(flex: (correctRatio * 100).toInt(), child: Container(color: const Color(0xFF10B981))),
                  Expanded(flex: (wrongRatio * 100).toInt(), child: Container(color: const Color(0xFFEF4444))),
                  Expanded(flex: (skippedRatio * 100).toInt(), child: Container(color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendBadge('Correct', '${breakdown.correct}', const Color(0xFF10B981), secondaryTextColor, textColor),
              _buildLegendBadge('Wrong', '${breakdown.wrong}', const Color(0xFFEF4444), secondaryTextColor, textColor),
              _buildLegendBadge('Skipped', '${breakdown.skipped}', const Color(0xFF94A3B8), secondaryTextColor, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBadge(String label, String value, Color color, Color secondaryTextColor, Color textColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }

  Widget _buildScoreTrend(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final trends = _analyticsData!.scoreTrend;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          if (trends.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'No score trend data available',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: trends.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final trend = trends[index];
                  final Color barColor = trend.percentage >= 70
                      ? const Color(0xFF10B981)
                      : trend.percentage >= 40
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${trend.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryTextColor),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: (trend.percentage / 100) * 60 + 4,
                        width: 18,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${trend.date.day}/${trend.date.month}',
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsights(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        ..._analyticsData!.insights.map((insight) {
          final isWarning = insight.type == 'warning';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWarning
                  ? (isDark ? const Color(0xFF2D1F0A) : const Color(0xFFFFFBEB))
                  : (isDark ? const Color(0xFF0A1A2E) : const Color(0xFFEFF6FF)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isWarning
                    ? (isDark ? const Color(0xFF8D6E1A) : const Color(0xFFFDE68A))
                    : (isDark ? const Color(0xFF1A3A6E) : const Color(0xFFBFDBFE)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline_rounded,
                  color: isWarning
                      ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706))
                      : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isWarning
                              ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFF92400E))
                              : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E40AF)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insight.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryPerformance(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          ..._analyticsData!.byCategory.map((cat) {
            final double progress = cat.totalMaxScore > 0 ? (cat.totalScore / cat.totalMaxScore).clamp(0.0, 1.0) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.label,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                      ),
                      Text(
                        '${cat.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      cat.percentage >= 50 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRetakeProgress(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Retake Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          ..._analyticsData!.retakeProgress.map((retake) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF12121E) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  retake.testTitle,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'First: ${retake.firstPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 11, color: secondaryTextColor),
                    ),
                    Icon(
                      Icons.arrow_right_alt_rounded,
                      size: 16,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                    Text(
                      'Latest: ${retake.latestPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2563EB)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: retake.improved
                            ? (isDark ? const Color(0xFF1A3A1A) : const Color(0xFFDCFCE7))
                            : (isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${retake.improved ? '+' : ''}${retake.improvement.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: retake.improved
                              ? (isDark ? const Color(0xFF4CAF50) : const Color(0xFF166534))
                              : (isDark ? const Color(0xFFEF5350) : const Color(0xFF991B1B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecentAttempts(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final attempts = _analyticsData!.recentAttempts.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Attempts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          ...attempts.map((attempt) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF12121E) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: attempt.percentage >= 50
                      ? (isDark ? const Color(0xFF1A3A1A) : const Color(0xFFDCFCE7))
                      : (isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFEE2E2)),
                  child: Text(
                    '${attempt.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: attempt.percentage >= 50
                          ? (isDark ? const Color(0xFF4CAF50) : const Color(0xFF15803D))
                          : (isDark ? const Color(0xFFEF5350) : const Color(0xFFB91C1C)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attempt.test.title,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        attempt.series.title,
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(attempt.submittedAt),
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSeriesPerformance(
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Series Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          ..._analyticsData!.bySeries.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF12121E) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.library_books_outlined,
                    size: 18,
                    color: isDark ? Colors.white38 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.seriesTitle,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.attemptsCount} Attempts',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark, Color cardColor, Color borderColor) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.white.withOpacity(0.03) : const Color(0x05000000),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _SummaryItem(this.label, this.value, this.icon, this.color);
}