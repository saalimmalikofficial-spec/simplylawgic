// lib/screens/test/attempt_report_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/models/attempt_report_model.dart';
import 'package:simplylawgic/services/api_service.dart';

class AttemptReportScreen extends StatefulWidget {
  final String attemptId;
  final String? testTitle;
  final String? seriesTitle;

  const AttemptReportScreen({
    super.key,
    required this.attemptId,
    this.testTitle,
    this.seriesTitle,
  });

  @override
  State<AttemptReportScreen> createState() => _AttemptReportScreenState();
}

class _AttemptReportScreenState extends State<AttemptReportScreen> {
  static const _primary = Color(0xFF2563EB);
  static const _success = Color(0xFF10B981);
  static const _danger = Color(0xFFEF4444);
  static const _warning = Color(0xFFF59E0B);
  static const _skipped = Color(0xFF94A3B8);

  final ApiService _apiService = ApiService();

  AttemptReport? _report;
  bool _isLoading = true;
  String? _errorMessage;

  int _selectedFilter = 0; // 0=All, 1=Correct, 2=Wrong, 3=Skipped

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getAttemptReport(widget.attemptId);
      if (!mounted) return;
      setState(() {
        _report = AttemptReport.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<ReportQuestion> get _filteredQuestions {
    final all = _report?.breakdown ?? [];
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F6FA);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isDark, textColor),
            Expanded(
              child: _isLoading
                  ? _buildLoader(isDark)
                  : _errorMessage != null
                  ? _buildError(isDark)
                  : _buildContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================
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
              child:
              Icon(Icons.arrow_back_rounded, size: 20, color: textColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (_report?.test?.title != null)
                  Text(
                    _report!.test!.title,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                      isDark ? Colors.white54 : const Color(0xFF7A869A),
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

  // ============================================================
  // LOADER / ERROR
  // ============================================================
  Widget _buildLoader(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? Colors.white : _primary,
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: isDark ? const Color(0xFFEF5350) : _danger,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load report',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchReport,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : _primary,
                foregroundColor:
                isDark ? const Color(0xFF0A0A0F) : Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================
  Widget _buildContent(bool isDark) {
    final r = _report!;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF4A5568);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreCard(isDark),
          const SizedBox(height: 16),
          _buildStatsGrid(isDark, cardColor),
          const SizedBox(height: 16),
          _buildMetaCard(isDark, cardColor, textColor, secondaryTextColor),
          const SizedBox(height: 20),
          _buildFilterTabs(isDark, cardColor, textColor),
          const SizedBox(height: 12),
          _buildQuestionList(isDark, cardColor, textColor),
        ],
      ),
    );
  }

  // ============================================================
  // SCORE CARD
  // ============================================================
  Widget _buildScoreCard(bool isDark) {
    final r = _report!;
    final percentage = r.percentage;

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
                const Icon(Icons.assessment_rounded,
                    size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  r.status.toUpperCase(),
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
                    value: (percentage / 100).clamp(0.0, 1.0),
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
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF5C842),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percentage >= 70
                ? 'Excellent! 🎉'
                : percentage >= 40
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

  // ============================================================
  // STATS GRID
  // ============================================================
  Widget _buildStatsGrid(bool isDark, Color cardColor) {
    final r = _report!;
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
              isDark, cardColor, 'Correct', '${r.correctCount}', _success),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(
              isDark, cardColor, 'Wrong', '${r.wrongCount}', _danger),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatBox(
              isDark, cardColor, 'Skipped', '${r.skippedCount}', _skipped),
        ),
      ],
    );
  }

  Widget _buildStatBox(bool isDark, Color cardColor, String label, String value,
      Color color) {
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
            child: Icon(Icons.circle, color: color, size: 14),
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

  // ============================================================
  // META CARD
  // ============================================================
  Widget _buildMetaCard(bool isDark, Color cardColor, Color textColor,
      Color secondaryTextColor) {
    final r = _report!;
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
        children: [
          _buildMetaRow(
            Icons.timer_outlined,
            'Time Taken',
            r.formattedTimeTaken,
            isDark,
            textColor,
          ),
          const SizedBox(height: 12),
          _buildMetaRow(
            Icons.percent_rounded,
            'Accuracy',
            '${r.accuracy.toStringAsFixed(1)}%',
            isDark,
            textColor,
          ),
          if (r.series?.title != null && r.series!.title.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMetaRow(
              Icons.library_books_outlined,
              'Series',
              r.series!.title,
              isDark,
              textColor,
            ),
          ],
          if (r.submittedAt != null) ...[
            const SizedBox(height: 12),
            _buildMetaRow(
              Icons.calendar_today_outlined,
              'Submitted',
              _formatDateTime(r.submittedAt!),
              isDark,
              textColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value, bool isDark,
      Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _primary.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: _primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? Colors.white54 : const Color(0xFF7A869A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER TABS
  // ============================================================
  Widget _buildFilterTabs(bool isDark, Color cardColor, Color textColor) {
    final r = _report!;
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

  // ============================================================
  // QUESTION LIST
  // ============================================================
  Widget _buildQuestionList(bool isDark, Color cardColor, Color textColor) {
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
        return _buildQuestionCard(
            questions[index], index, isDark, cardColor, textColor);
      },
    );
  }

  Widget _buildQuestionCard(ReportQuestion q, int index, bool isDark,
      Color cardColor, Color textColor) {
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
                    color:
                    isDark ? Colors.white70 : const Color(0xFF4A5568),
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
                color: isDark
                    ? const Color(0xFF0A1A2E)
                    : const Color(0xFFEFF6FF),
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
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF334155),
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

  // ✅ FIXED: `ampm` (lowercase) — pehle `amPm` tha
  String _formatDateTime(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = date.day.toString().padLeft(2, '0');
    final m = months[date.month - 1];
    final y = date.year;
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final min = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$d $m $y, $h:$min $ampm';
  }
}

class _FilterTab {
  final String label;
  final int count;
  final Color color;
  _FilterTab(this.label, this.count, this.color);
}