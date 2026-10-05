// lib/screens/tests/test_instruction_before_start.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/models/attempt_statusResponse.dart';
import 'package:simplylawgic/screens/test/test_result_screen.dart';
import 'package:simplylawgic/services/api_service.dart';

class TestInstructionBeforeStart extends StatelessWidget {
  final String testTitle;
  final String seriesTitle;
  final String instructions;
  final int durationMinutes;
  final int questionCount;
  final int totalMarks;
  final double negativeMarks;
  final VoidCallback onStart;
  final VoidCallback onExit;

  // ✅ NEW: Agar already completed hai, toh yeh non-null hoga
  final AttemptStatusResponse? alreadyCompletedData;

  const TestInstructionBeforeStart({
    super.key,
    required this.testTitle,
    required this.seriesTitle,
    required this.instructions,
    required this.durationMinutes,
    required this.questionCount,
    required this.totalMarks,
    required this.negativeMarks,
    required this.onStart,
    required this.onExit,
    this.alreadyCompletedData,
  });

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F6FA);

    // ✅ Agar already completed hai, toh result UI dikhao
    if (alreadyCompletedData != null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(isDark),
              Expanded(
                child: _buildAlreadyCompletedView(context, isDark),
              ),
            ],
          ),
        ),
      );
    }

    // Normal instruction UI
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0E4EC);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF4A5568);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(isDark),
                    const SizedBox(height: 16),
                    _buildInstructionsCard(isDark, cardColor, borderColor,
                        textColor, secondaryTextColor),
                    const SizedBox(height: 16),
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ NEW: ALREADY COMPLETED VIEW
  // ============================================================
  Widget _buildAlreadyCompletedView(BuildContext context, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF4A5568);

    final data = alreadyCompletedData!;
    final percentage = data.maxScore == 0
        ? 0.0
        : (data.score / data.maxScore) * 100;

    final Color scoreColor;
    if (percentage >= 70) {
      scoreColor = const Color(0xFF10B981);
    } else if (percentage >= 40) {
      scoreColor = const Color(0xFFF59E0B);
    } else {
      scoreColor = const Color(0xFFEF4444);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Warning icon (orange)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                size: 42,
                color: Color(0xFFEA580C),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'You have already completed this test.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can view your result below.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 28),

          // ✅ Mini score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFE0E4EC),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(isDark ? 0.25 : 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _miniStat(
                      isDark,
                      'Score',
                      '${data.score}/${data.maxScore}',
                      scoreColor,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : const Color(0xFFEEF1F7),
                    ),
                    _miniStat(
                      isDark,
                      'Accuracy',
                      '${percentage.toStringAsFixed(0)}%',
                      scoreColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniCounter(
                        'Correct', data.correctCount, const Color(0xFF10B981)),
                    _miniCounter(
                        'Wrong', data.wrongCount, const Color(0xFFEF4444)),
                    _miniCounter(
                        'Skipped', data.skippedCount, const Color(0xFF94A3B8)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ✅ View Result button (primary)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestResultScreen(result: data),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'View Full Result',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ Retry (Go back) button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onExit,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0xFF7A869A),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: textColor,
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(bool isDark, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _miniCounter(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A869A),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================
  Widget _buildTopHeader(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF12121E) : const Color(0xFF0B1B3A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5C842),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'SL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1B3A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalizeTitle(seriesTitle).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _capitalizeTitle(testTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onExit,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            child: const Text(
              'Exit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS ROW
  // ============================================================
  Widget _buildStatsRow(bool isDark) {
    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard(
            isDark: isDark,
            label: 'DURATION',
            value: '$durationMinutes min',
            icon: Icons.timer_outlined,
            valueColor: isDark ? Colors.white : const Color(0xFF0B1B3A),
            iconColor: const Color(0xFF2E7D5B),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            isDark: isDark,
            label: 'QUESTIONS',
            value: '$questionCount',
            icon: Icons.help_outline_rounded,
            valueColor: isDark ? Colors.white : const Color(0xFF0B1B3A),
            iconColor: const Color(0xFF1A3A8F),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            isDark: isDark,
            label: 'TOTAL MARKS',
            value: '$totalMarks',
            icon: Icons.workspace_premium_outlined,
            valueColor: isDark ? Colors.white : const Color(0xFF0B1B3A),
            iconColor: const Color(0xFFD4A24A),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            isDark: isDark,
            label: 'NEGATIVE',
            value: '-$negativeMarks',
            icon: Icons.warning_amber_rounded,
            valueColor:
            isDark ? const Color(0xFFEF5350) : const Color(0xFFB71C1C),
            iconColor: const Color(0xFFB71C1C),
            bgColor:
            isDark ? const Color(0xFF2D1B1B) : const Color(0xFFFFF4E5),
            borderColor:
            isDark ? const Color(0xFF4A2020) : const Color(0xFFFFE0B2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
    required Color iconColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    final effectiveBg =
        bgColor ?? (isDark ? const Color(0xFF1A1A2E) : Colors.white);
    final effectiveBorder = borderColor ??
        (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE0E4EC));

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: effectiveBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : const Color(0xFF7A869A),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN INSTRUCTIONS CARD (existing code — unchanged)
  // ============================================================
  Widget _buildInstructionsCard(bool isDark, Color cardColor,
      Color borderColor, Color textColor, Color secondaryTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('General Instructions:', textColor),
          const SizedBox(height: 10),
          _paragraph(
            'The clock will be set at the server. The countdown timer in the top center of the screen will display the time remaining for you to complete the exam. When the timer reaches zero, the examination will end by itself. You will not be required to end or submit your examination.',
            secondaryTextColor,
          ),
          const SizedBox(height: 12),
          _paragraph(
            'The Question Palette displayed on the right side of the screen will show the status of each question using one of the following symbols:',
            secondaryTextColor,
          ),
          const SizedBox(height: 12),
          _buildLegendBox(isDark),
          const SizedBox(height: 14),
          _paragraphRich([
            _plain('The ', secondaryTextColor),
            _bold('Marked for Review', textColor),
            _plain(
                ' status for a question simply indicates that you would like to look at that question again. If a question is answered and marked for review, your answer for that question will be considered in the evaluation.',
                secondaryTextColor),
          ]),
          const SizedBox(height: 18),
          if (instructions.trim().isNotEmpty) ...[
            _sectionTitle('Test Instructions :', textColor),
            const SizedBox(height: 10),
            _buildDynamicInstructionsBox(instructions, isDark),
            const SizedBox(height: 18),
          ],
          _sectionTitle('Answering a Question :', textColor),
          const SizedBox(height: 10),
          _paragraph(
            'Procedure for answering a multiple choice (MCQ) type question:',
            secondaryTextColor,
          ),
          const SizedBox(height: 8),
          _bullet('To select your answer, click on the option button.',
              secondaryTextColor),
          _bullet(
              'To deselect your chosen answer, click on the option button again or click on the Clear Response button.',
              secondaryTextColor),
          _bullet('To change your chosen answer, click on another option button.',
              secondaryTextColor),
          _bullet(
              'To save your answer, you MUST click on the Save & Next button.',
              secondaryTextColor),
          const SizedBox(height: 12),
          _paragraphRich([
            _plain('To mark a question for review, click on the ',
                secondaryTextColor),
            _bold('Mark for Review & Next', textColor),
            _plain(
                ' button. You can still change your answer later before submitting the test.',
                secondaryTextColor),
          ]),
          const SizedBox(height: 10),
          _paragraphRich([
            _plain('After clicking ', secondaryTextColor),
            _bold('Save & Next', textColor),
            _plain(
                ' for the last question, you will still be able to go back and modify answers until you submit the test, or until the timer ends.',
                secondaryTextColor),
          ]),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
              isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF0F2F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              'Please read the instructions carefully. Once you start the test, the timer will begin and remaining time will stay synced with the server.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicInstructionsBox(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D1F0A) : const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF4A3520) : const Color(0xFFFFE0A3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color:
              isDark ? const Color(0xFFF59E0B) : const Color(0xFFD4A24A),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.6,
                color: isDark ? Colors.white70 : const Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE0E4EC),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendRow(
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.white,
            borderColor:
            isDark ? Colors.white54 : const Color(0xFFCBD2DC),
            label: 'You have not visited the question yet.',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFFD4A24A),
            label: 'You have not answered the question.',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFF2E7D5B),
            label: 'You have answered the question.',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFF7B3FB8),
            label:
            'You have NOT answered the question, but have marked the question for review.',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFF1A3A8F),
            label: 'You have answered the question, but marked it for review.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _legendRow({
    required Color color,
    required String label,
    required bool isDark,
    Color borderColor = Colors.transparent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18,
          width: 18,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: borderColor == Colors.transparent
                  ? color.withValues(alpha: 0.4)
                  : borderColor,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? Colors.white70 : const Color(0xFF4A5568),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'I am ready to begin',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onExit,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7A869A), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: const Color(0xFF0B1B3A),
              ),
              child: const Text(
                'Go back',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT HELPERS
  // ============================================================
  Widget _sectionTitle(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFF5C842),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _paragraph(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.5, height: 1.6, color: color),
    );
  }

  Widget _bullet(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 5, color: color),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, height: 1.6, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paragraphRich(List<TextSpan> spans) {
    return Text.rich(
      TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 12.5, height: 1.6),
      ),
    );
  }

  TextSpan _plain(String text, Color color) =>
      TextSpan(text: text, style: TextStyle(color: color));

  TextSpan _bold(String text, Color color) => TextSpan(
    text: text,
    style: TextStyle(fontWeight: FontWeight.bold, color: color),
  );
}