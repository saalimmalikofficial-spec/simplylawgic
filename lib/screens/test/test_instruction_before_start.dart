// lib/screens/tests/test_instruction_before_start.dart
import 'package:flutter/material.dart';

class TestInstructionBeforeStart extends StatelessWidget {
  // 🔥 API se aane wala dynamic data
  final String testTitle;
  final String seriesTitle;
  final String instructions;
  final int durationMinutes;
  final int questionCount;
  final int totalMarks;
  final double negativeMarks;
  final VoidCallback onStart;
  final VoidCallback onExit;

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
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildInstructionsCard(),
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
  // TOP HEADER — dynamic title
  // ============================================================
  Widget _buildTopHeader() {
    return Container(
      color: const Color(0xFF0B1B3A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5C842),
              borderRadius: BorderRadius.circular(6),
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
                // 🔥 Series title
                Text(
                  seriesTitle.toUpperCase(),
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
                // 🔥 Test title
                Text(
                  testTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
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
  // STATS ROW — dynamic values
  // ============================================================
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'DURATION',
            value: '$durationMinutes min',
            valueColor: const Color(0xFF0B1B3A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: 'QUESTIONS',
            value: '$questionCount',
            valueColor: const Color(0xFF0B1B3A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: 'TOTAL MARKS',
            value: '$totalMarks',
            valueColor: const Color(0xFF0B1B3A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: 'NEGATIVE MARKING',
            value: '-$negativeMarks',
            valueColor: const Color(0xFFB71C1C),
            bgColor: const Color(0xFFFFF4E5),
            borderColor: const Color(0xFFFFE0B2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
    Color bgColor = Colors.white,
    Color borderColor = const Color(0xFFE0E4EC),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A869A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
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
  // MAIN INSTRUCTIONS CARD
  // ============================================================
  Widget _buildInstructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E4EC), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Instructions
          _sectionTitle('General Instructions:'),
          const SizedBox(height: 10),
          _paragraph(
            'The clock will be set at the server. The countdown timer in the top center of the screen will display the time remaining for you to complete the exam. When the timer reaches zero, the examination will end by itself. You will not be required to end or submit your examination.',
          ),
          const SizedBox(height: 12),
          _paragraph(
            'The Question Palette displayed on the right side of the screen will show the status of each question using one of the following symbols:',
          ),
          const SizedBox(height: 12),

          _buildLegendBox(),

          const SizedBox(height: 14),
          _paragraphRich([
            _plain('The '),
            _bold('Marked for Review'),
            _plain(
                ' status for a question simply indicates that you would like to look at that question again. If a question is answered and marked for review, your answer for that question will be considered in the evaluation.'),
          ]),

          const SizedBox(height: 18),

          // 🔥 DYNAMIC instructions from API
          if (instructions.trim().isNotEmpty) ...[
            _sectionTitle('Test Instructions :'),
            const SizedBox(height: 10),
            _buildDynamicInstructionsBox(instructions),
            const SizedBox(height: 18),
          ],

          // Answering a Question
          _sectionTitle('Answering a Question :'),
          const SizedBox(height: 10),
          _paragraph(
            'Procedure for answering a multiple choice (MCQ) type question:',
          ),
          const SizedBox(height: 8),
          _bullet('To select your answer, click on the option button.'),
          _bullet(
              'To deselect your chosen answer, click on the option button again or click on the Clear Response button.'),
          _bullet('To change your chosen answer, click on another option button.'),
          _bullet('To save your answer, you MUST click on the Save & Next button.'),

          const SizedBox(height: 12),
          _paragraphRich([
            _plain('To mark a question for review, click on the '),
            _bold('Mark for Review & Next'),
            _plain(
                ' button. You can still change your answer later before submitting the test.'),
          ]),

          const SizedBox(height: 10),
          _paragraphRich([
            _plain('After clicking '),
            _bold('Save & Next'),
            _plain(
                ' for the last question, you will still be able to go back and modify answers until you submit the test, or until the timer ends.'),
          ]),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E4EC), width: 1),
            ),
            child: const Text(
              'Please read the instructions carefully. Once you start the test, the timer will begin and remaining time will stay synced with the server.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 DYNAMIC instructions box (amber)
  Widget _buildDynamicInstructionsBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE0A3), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          height: 1.6,
          color: Color(0xFF4A5568),
        ),
      ),
    );
  }

  // ============================================================
  // LEGEND BOX
  // ============================================================
  Widget _buildLegendBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E4EC), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendRow(
            color: Colors.white,
            borderColor: const Color(0xFFCBD2DC),
            label: 'You have not visited the question yet.',
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFFD4A24A),
            label: 'You have not answered the question.',
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFF2E7D5B),
            label: 'You have answered the question.',
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFF7B3FB8),
            label:
            'You have NOT answered the question, but have marked the question for review.',
          ),
          const SizedBox(height: 10),
          _legendRow(
            color: const Color(0xFF1A3A8F),
            label:
            'You have answered the question, but marked it for review.',
          ),
        ],
      ),
    );
  }

  Widget _legendRow({
    required Color color,
    required String label,
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
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM ACTIONS — callbacks
  // ============================================================
  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              // 🔥 parent callback — "I am ready to begin"
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'I am ready to begin',
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
            child: OutlinedButton(
              onPressed: onExit,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7A869A), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0B1B3A),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        height: 1.6,
        color: Color(0xFF4A5568),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(
              Icons.circle,
              size: 5,
              color: Color(0xFF4A5568),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.6,
                color: Color(0xFF4A5568),
              ),
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
        style: const TextStyle(
          fontSize: 12.5,
          height: 1.6,
          color: Color(0xFF4A5568),
        ),
      ),
    );
  }

  TextSpan _plain(String text) => TextSpan(text: text);

  TextSpan _bold(String text) => TextSpan(
    text: text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF0B1B3A),
    ),
  );

  TextSpan _boldRed(String text) => TextSpan(
    text: text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFFB71C1C),
    ),
  );
}