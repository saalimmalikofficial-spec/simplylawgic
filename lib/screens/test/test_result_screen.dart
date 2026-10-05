// lib/screens/test/test_result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simplylawgic/models/attempt_report_model.dart';
import 'package:simplylawgic/models/attempt_statusResponse.dart';
import 'package:simplylawgic/screens/test/test_attempt_screen.dart';

class TestResultScreen extends StatefulWidget {
  final AttemptStatusResponse result;
  final String? seriesSlug;
  final String? testId;

  const TestResultScreen({
    super.key,
    required this.result,
    this.seriesSlug,
    this.testId,
  });

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  static const _primary = Color(0xFF2563EB);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);
  static const _skipped = Color(0xFF94A3B8);

  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  List<ReportQuestion> get _filteredQuestions {
    final all = widget.result.breakdown;
    switch (_selectedFilter) {
      case 1:
        return all.where((q) => q.isCorrect).toList();
      case 2:
        return all.where((q) => q.isWrong).toList();
      case 3:
        return all.where((q) => q.isSkipped).toList();
      default:
        return all;
    }
  }

  double get _scorePercentage {
    if (widget.result.maxScore == 0) return 0;
    return (widget.result.score / widget.result.maxScore) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F6FA);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF4A5568);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isDark, textColor),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreHeroCard(isDark),
                    const SizedBox(height: 16),
                    _buildStatsGrid(isDark, cardColor),
                    if (widget.result.previousAttempts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildAttemptsHistory(
                          isDark, cardColor, textColor, secondaryTextColor),
                    ],
                    const SizedBox(height: 20),
                    _buildFilterTabs(isDark, cardColor, textColor),
                    const SizedBox(height: 12),
                    _buildQuestionList(
                        isDark, cardColor, textColor, secondaryTextColor),
                    const SizedBox(height: 24),
                    _buildBottomActions(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE0E4EC),
                ),
              ),
              child: Icon(Icons.close_rounded, size: 20, color: textColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test Result',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (widget.result.test?.title != null)
                  Text(
                    widget.result.test!.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : const Color(0xFF7A869A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeroCard(bool isDark) {
    final r = widget.result;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A2B4A), const Color(0xFF0F1B33)]
              : [_primary, const Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  r.isSubmitted ? 'SUBMITTED' : r.phase.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: _scorePercentage / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF5C842),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${r.score}',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'out of ${r.maxScore}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_scorePercentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF5C842),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _scorePercentage >= 70
                ? 'Excellent! 🎉'
                : _scorePercentage >= 40
                ? 'Good effort! 💪'
                : 'Keep practicing! 📚',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark, Color cardColor) {
    final r = widget.result;
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(isDark, cardColor, 'Correct',
              '${r.correctCount}', _success, Icons.check_circle_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(isDark, cardColor, 'Wrong', '${r.wrongCount}',
              _danger, Icons.cancel_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(isDark, cardColor, 'Skipped',
              '${r.skippedCount}', _skipped, Icons.remove_circle_rounded),
        ),
      ],
    );
  }

  Widget _buildStatBox(bool isDark, Color cardColor, String label, String value,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE0E4EC),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0B1B3A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : const Color(0xFF7A869A),
            ),
          ),
        ],
      ),
    );
  }

  // ============ ATTEMPT HISTORY ============
  Widget _buildAttemptsHistory(bool isDark, Color cardColor, Color textColor,
      Color secondaryTextColor) {
    final attempts = widget.result.previousAttempts;
    final currentAttemptId = widget.result.attemptId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
              const Icon(Icons.history_rounded, size: 16, color: _primary),
            ),
            const SizedBox(width: 8),
            Text(
              'Attempt History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${attempts.length} ${attempts.length == 1 ? "attempt" : "attempts"}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(attempts.length, (index) {
          final attempt = attempts[index];
          final isCurrent = attempt.attemptId == currentAttemptId;
          final attemptNumber = attempts.length - index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildAttemptCard(
              attempt: attempt,
              attemptNumber: attemptNumber,
              isCurrent: isCurrent,
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAttemptCard({
    required PreviousAttempt attempt,
    required int attemptNumber,
    required bool isCurrent,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final pct = attempt.percentage;
    final Color statusColor;
    final IconData statusIcon;
    final String statusLabel;

    if (pct >= 70) {
      statusColor = _success;
      statusIcon = Icons.emoji_events_rounded;
      statusLabel = 'Great';
    } else if (pct >= 40) {
      statusColor = _warning;
      statusIcon = Icons.trending_up_rounded;
      statusLabel = 'Average';
    } else {
      statusColor = _danger;
      statusIcon = Icons.trending_down_rounded;
      statusLabel = 'Needs Work';
    }

    final dateStr = _formatDate(attempt.submittedAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? _primary
              : (isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE0E4EC)),
          width: isCurrent ? 1.8 : 1,
        ),
        boxShadow: isCurrent
            ? [
          BoxShadow(
            color: _primary.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isCurrent
                      ? const LinearGradient(
                      colors: [_primary, Color(0xFF1D4ED8)])
                      : null,
                  color: isCurrent
                      ? null
                      : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFF0F2F7)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#$attemptNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isCurrent
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF4A5568)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Attempt $attemptNumber',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LATEST',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${attempt.score}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                        TextSpan(
                          text: '/${attempt.maxScore}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildMiniStat(
                    'Correct', attempt.correctCount, _success, isDark),
                _buildMiniDivider(isDark),
                _buildMiniStat('Wrong', attempt.wrongCount, _danger, isDark),
                _buildMiniDivider(isDark),
                _buildMiniStat(
                    'Skipped', attempt.skippedCount, _skipped, isDark),
                const Spacer(),
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0B1B3A),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : const Color(0xFF7A869A),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniDivider(bool isDark) {
    return Container(
      width: 1,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE0E4EC),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    try {
      final local = dt.toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = local.hour > 12
          ? local.hour - 12
          : (local.hour == 0 ? 12 : local.hour);
      final ampm = local.hour >= 12 ? 'PM' : 'AM';
      final min = local.minute.toString().padLeft(2, '0');
      return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$min $ampm';
    } catch (_) {
      return 'N/A';
    }
  }

  // ============ FILTER TABS ============
  Widget _buildFilterTabs(bool isDark, Color cardColor, Color textColor) {
    final r = widget.result;
    final filters = [
      _FilterTab('All', r.breakdown.length, _primary),
      _FilterTab('Correct', r.correctCount, _success),
      _FilterTab('Wrong', r.wrongCount, _danger),
      _FilterTab('Skipped', r.skippedCount, _skipped),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color:
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = _selectedFilter == i;
          final f = filters[i];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? textColor
                            : (isDark
                            ? Colors.white54
                            : const Color(0xFF7A869A)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${f.count}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? f.color
                            : (isDark
                            ? Colors.white38
                            : const Color(0xFFB0B8C4)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============ QUESTION LIST ============
  Widget _buildQuestionList(bool isDark, Color cardColor, Color textColor,
      Color secondaryTextColor) {
    final questions = _filteredQuestions;

    if (questions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: isDark ? Colors.white24 : const Color(0xFFCBD2DC),
            ),
            const SizedBox(height: 12),
            Text(
              'No questions in this category',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF7A869A),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildQuestionCard(questions[index], index, isDark, cardColor,
            textColor, secondaryTextColor);
      },
    );
  }

  Widget _buildQuestionCard(ReportQuestion q, int index, bool isDark,
      Color cardColor, Color textColor, Color secondaryTextColor) {
    final Color statusColor;
    final IconData statusIcon;
    final String statusLabel;

    if (q.isCorrect) {
      statusColor = _success;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Correct';
    } else if (q.isWrong) {
      statusColor = _danger;
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'Wrong';
    } else {
      statusColor = _skipped;
      statusIcon = Icons.remove_circle_rounded;
      statusLabel = 'Skipped';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE0E4EC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Q${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : const Color(0xFF7A869A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${q.marks} ${q.marks == 1 ? "mark" : "marks"}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ...q.options.map((opt) {
            final isCorrectOption = opt.key == q.correctOption;
            final isSelectedOption = opt.key == q.selectedOption;

            Color borderColor = isDark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFE0E4EC);
            Color bgColor = Colors.transparent;
            Color optionTextColor = textColor;
            IconData? trailingIcon;

            if (isCorrectOption) {
              borderColor = _success;
              bgColor = _success.withOpacity(0.08);
              optionTextColor = _success;
              trailingIcon = Icons.check_circle_rounded;
            } else if (isSelectedOption && !isCorrectOption) {
              borderColor = _danger;
              bgColor = _danger.withOpacity(0.08);
              optionTextColor = _danger;
              trailingIcon = Icons.cancel_rounded;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCorrectOption
                          ? _success
                          : (isSelectedOption
                          ? _danger
                          : (isDark
                          ? Colors.white.withOpacity(0.08)
                          : const Color(0xFFF0F2F7))),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      opt.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (isCorrectOption || isSelectedOption)
                            ? Colors.white
                            : (isDark
                            ? Colors.white70
                            : const Color(0xFF4A5568)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      opt.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: optionTextColor,
                        fontWeight: (isCorrectOption || isSelectedOption)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(trailingIcon, size: 18, color: optionTextColor),
                ],
              ),
            );
          }),
          if (q.explanation.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                isDark ? const Color(0xFF0A1A2E) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1A3A6E)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF60A5FA) : _primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Explanation',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF60A5FA) : _primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.explanation,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color:
                      isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============ BOTTOM ACTIONS ============
  Widget _buildBottomActions(bool isDark) {
    final canRetake = widget.result.canRetake;

    return Row(
      children: [
        if (canRetake) ...[
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();

                  // Check karo ki testId aur seriesSlug available hain
                  final slug = widget.seriesSlug ??
                      widget.result.series?.slug;
                  final tId = widget.testId ??
                      widget.result.test?.id;
                  final title = widget.result.test?.title ?? 'Test';

                  if (slug == null || slug.isEmpty || tId == null || tId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot retake: missing test info'),
                        backgroundColor: _danger,
                      ),
                    );
                    return;
                  }

                  // Purani screens ko replace karo — retake screen push karo
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TestAttemptScreen(
                        seriesSlug: slug,
                        testId: tId,
                        testTitle: title,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Retake',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : _primary,
                foregroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Tests',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterTab {
  final String label;
  final int count;
  final Color color;
  _FilterTab(this.label, this.count, this.color);
}