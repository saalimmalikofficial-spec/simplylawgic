// lib/screens/tests/test_attempt_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/screens/test/test_instruction_before_start.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/utils/app_colors.dart';

import 'dart:async';

class TestAttemptScreen extends StatefulWidget {
  final String seriesSlug;
  final String testId;
  final String testTitle;

  const TestAttemptScreen({
    super.key,
    required this.seriesSlug,
    required this.testId,
    required this.testTitle,
  });

  @override
  State<TestAttemptScreen> createState() => _TestAttemptScreenState();
}

class _TestAttemptScreenState extends State<TestAttemptScreen> {
  Map<String, dynamic>? _attemptData;
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _answers = [];
  List<String> _markedQuestions = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  bool _isTestSubmitted = false;
  String? _errorMessage;
  int _currentQuestionIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  Timer? _syncTimer;
  final ApiService _apiService = ApiService();

  // 🔥🔥🔥 2-phase flow
  bool _showInstructions = true;

  // 🔥 Dynamic test meta from API
  String _testTitle = '';
  String _seriesTitle = '';
  String _testInstructions = '';
  int _durationMinutes = 0;
  int _questionCount = 0;
  int _totalMarks = 0;
  double _negativeMarks = 0.0;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // 🔥 _startTest — API se data lekar instruction screen dikhao
  // ============================================================
  Future<void> _startTest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isTestSubmitted = false;
      _showInstructions = true;
    });

    try {
      final data = await _apiService.startTestAttempt(
        widget.seriesSlug,
        widget.testId,
      );

      if (data['status'] == 'submitted' || data['status'] == 'completed') {
        setState(() {
          _isTestSubmitted = true;
          _errorMessage = 'This test has already been submitted.';
          _isLoading = false;
        });
        return;
      }

      // 🔥 Extract test + series meta
      final test = (data['test'] as Map<String, dynamic>?) ?? {};
      final series = (data['series'] as Map<String, dynamic>?) ?? {};

      setState(() {
        _attemptData = data;
        _questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        _answers = List<Map<String, dynamic>>.from(data['answers'] ?? []);
        _markedQuestions = List<String>.from(data['markedQuestionIds'] ?? []);
        _remainingSeconds = data['remainingSeconds'] ?? 0;

        // 🔥 Dynamic values
        _testTitle = (test['title'] ?? widget.testTitle).toString();
        _seriesTitle = (series['title'] ?? '').toString();
        _testInstructions = (test['instructions'] ?? '').toString();
        _durationMinutes = (test['durationMinutes'] as num?)?.toInt() ?? 0;
        _questionCount =
            (test['questionCount'] as num?)?.toInt() ?? _questions.length;
        _totalMarks = (test['totalMarks'] as num?)?.toInt() ?? 0;
        _negativeMarks =
            ((test['negativeMarksPerWrong'] as num?)?.toDouble()) ?? 0.0;

        _isLoading = false;
        _showInstructions = true; // 🔥 instruction screen show
      });

      // ❌ Timer abhi start nahi karna — "I am ready to begin" ke baad
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      if (errorMsg.contains('already submitted') ||
          errorMsg.contains('submitted')) {
        setState(() {
          _isTestSubmitted = true;
          _errorMessage = 'This test has already been submitted.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
    }
  }

  // 🔥 User ne "I am ready to begin" tap kiya
  void _onUserReadyToBegin() {
    setState(() {
      _showInstructions = false;
    });

    // 🔥 AB timer + auto-sync start karo
    _startTimer();
    _startAutoSync();
  }

  // ---------- Timer ----------
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _syncTimer?.cancel();
          _autoSubmitTest();
        }
      });
    });
  }

  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _syncAnswers();
    });
  }

  Future<void> _syncAnswers() async {
    if (_isSyncing || _isTestSubmitted) return;

    final attemptId = _attemptData?['attemptId'] ?? '';
    if (attemptId.isEmpty) return;

    final answersToSync = _answers
        .where((a) => a['selectedOption']?.isNotEmpty ?? false)
        .map((a) => {
      'questionId': a['questionId'],
      'selectedOption': a['selectedOption'],
    })
        .toList();

    if (answersToSync.isEmpty) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      await _apiService.syncAnswers(attemptId, answersToSync);
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _autoSubmitTest() {
    if (_isTestSubmitted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time expired! Auto-submitting test...'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _submitTestAttempt();
  }

  void _selectOption(String questionId, String optionKey) {
    if (_isTestSubmitted) return;

    HapticFeedback.lightImpact();

    setState(() {
      final index = _answers.indexWhere((a) => a['questionId'] == questionId);
      if (index != -1) {
        if (_answers[index]['selectedOption'] == optionKey) {
          _answers[index]['selectedOption'] = '';
          _submitAnswer(questionId, '');
        } else {
          _answers[index]['selectedOption'] = optionKey;
          _submitAnswer(questionId, optionKey);
        }
      }
    });
  }

  void _clearSelection(String questionId) {
    if (_isTestSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      final index = _answers.indexWhere((a) => a['questionId'] == questionId);
      if (index != -1) {
        _answers[index]['selectedOption'] = '';
      }
    });
    _submitAnswer(questionId, '');
  }

  Future<void> _submitAnswer(String questionId, String optionKey) async {
    if (_isTestSubmitted) return;

    try {
      final attemptId = _attemptData?['attemptId'] ?? '';
      await _apiService.submitAnswer(attemptId, questionId, optionKey);
    } catch (e) {
      // quietly
    }
  }

  void _toggleMarkQuestion(String questionId) {
    if (_isTestSubmitted) return;

    HapticFeedback.selectionClick();

    setState(() {
      if (_markedQuestions.contains(questionId)) {
        _markedQuestions.remove(questionId);
      } else {
        _markedQuestions.add(questionId);
      }
    });
    _markQuestion(questionId);
  }

  Future<void> _markQuestion(String questionId) async {
    if (_isTestSubmitted) return;

    try {
      final attemptId = _attemptData?['attemptId'] ?? '';
      final marked = _markedQuestions.contains(questionId);
      await _apiService.markQuestion(attemptId, questionId, marked);
    } catch (e) {
      // quietly
    }
  }

  String _getSelectedOption(String questionId) {
    final answer = _answers.firstWhere(
          (a) => a['questionId'] == questionId,
      orElse: () => {'selectedOption': ''},
    );
    return answer['selectedOption'] ?? '';
  }

  bool _isQuestionAnswered(String questionId) {
    return _getSelectedOption(questionId).isNotEmpty;
  }

  bool _isQuestionMarked(String questionId) {
    return _markedQuestions.contains(questionId);
  }

  int _getAnsweredCount() {
    return _answers
        .where((a) => a['selectedOption']?.isNotEmpty ?? false)
        .length;
  }

  // ---------- Submit ----------
  void _submitTest() {
    if (_isTestSubmitted) return;

    final answeredCount = _getAnsweredCount();
    final totalQuestions = _questions.length;
    final unattempted = totalQuestions - answeredCount;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final dialogText = isDark ? Colors.white : AppColors.textDark;
    final dialogSubtext = isDark ? Colors.white70 : AppColors.textSecondary;
    final dialogBorder =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        backgroundColor: dialogBg,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Submit Test',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: dialogText,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to finish and submit your test attempt?',
                style: TextStyle(
                  fontSize: 13,
                  color: dialogSubtext,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0A0A0F) : AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dialogBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                          'Answered', '$answeredCount', AppColors.secondary),
                    ),
                    Container(width: 1, height: 32, color: dialogBorder),
                    Expanded(
                      child: _buildStatItem(
                          'Unattempted', '$unattempted', AppColors.danger),
                    ),
                    Container(width: 1, height: 32, color: dialogBorder),
                    Expanded(
                      child: _buildStatItem('Marked',
                          '${_markedQuestions.length}', Colors.amber.shade800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: dialogBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: dialogText,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _submitTestAttempt();
                        },
                        child: const Text(
                          'Submit Now',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  void _submitTestAttempt() async {
    if (_isTestSubmitted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _syncAnswers();

      final attemptId = _attemptData?['attemptId'] ?? '';
      await _apiService.submitTest(attemptId);

      _timer?.cancel();
      _syncTimer?.cancel();

      setState(() {
        _isTestSubmitted = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test submitted successfully!'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        _isLoading = false;
        if (errorMsg.contains('already submitted')) {
          _isTestSubmitted = true;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ---------- Question Palette ----------
  void _showQuestionPalette() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : AppColors.bg;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question Palette',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 20, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPaletteLegend(AppColors.secondary, 'Answered'),
                      _buildPaletteLegend(Colors.amber.shade800, 'Marked'),
                      _buildPaletteLegend(
                        bgColor,
                        'Unanswered',
                        textColor: textColor,
                        border: borderColor,
                      ),
                    ],
                  ),
                  Divider(height: 24, color: borderColor),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final qId = _questions[index]['_id'] ?? '';
                        final isAnswered = _isQuestionAnswered(qId);
                        final isMarked = _isQuestionMarked(qId);
                        final isCurrent = index == _currentQuestionIndex;

                        Color bg = bgColor;
                        Color textClr = textColor;
                        Border border = Border.all(color: borderColor);

                        if (isAnswered) {
                          bg = AppColors.secondary;
                          textClr = Colors.white;
                          border = Border.all(color: AppColors.secondary);
                        } else if (isMarked) {
                          bg = Colors.amber.shade800;
                          textClr = Colors.white;
                          border = Border.all(color: Colors.amber.shade800);
                        }

                        return InkWell(
                          onTap: () {
                            setState(() => _currentQuestionIndex = index);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(10),
                              border: isCurrent
                                  ? Border.all(
                                  color: AppColors.primary, width: 2.5)
                                  : border,
                              boxShadow: isCurrent
                                  ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withOpacity(0.3),
                                  blurRadius: 6,
                                )
                              ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: textClr,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaletteLegend(Color color, String label,
      {Color textColor = Colors.white, Color? border}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border != null ? Border.all(color: border) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor == Colors.white
                ? AppColors.textSecondary
                : textColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD — 2-phase flow
  // ============================================================
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
    final appBarBg = isDark ? const Color(0xFF12121E) : AppColors.background;

    // 🔥 1. Loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      );
    }

    // 🔥 2. Error
    if (_errorMessage != null && !_isTestSubmitted) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarBg,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.testTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
        body: _buildErrorView(isDark),
      );
    }

    // 🔥🔥🔥 3. INSTRUCTION SCREEN
    if (_showInstructions && !_isTestSubmitted) {
      return TestInstructionBeforeStart(
        testTitle: _testTitle,
        seriesTitle: _seriesTitle,
        instructions: _testInstructions,
        durationMinutes: _durationMinutes,
        questionCount: _questionCount,
        totalMarks: _totalMarks,
        negativeMarks: _negativeMarks,
        onStart: _onUserReadyToBegin,
        onExit: () => Navigator.pop(context),
      );
    }

    // 🔥 4. TEST SCREEN
    return PopScope(
      canPop: _isTestSubmitted,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            title: Text(
              'Exit Test?',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            content: Text(
              'Your progress is saved dynamically. Are you sure you want to exit?',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Resume',
                    style: TextStyle(color: AppColors.primary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit Test'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: appBarBg,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: textColor),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            _isTestSubmitted ? 'Test Result' : _testTitle, // 🔥 dynamic
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_isSyncing)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
            if (!_isTestSubmitted && !_isLoading && _questions.isNotEmpty)
              IconButton(
                icon: Icon(Icons.grid_view_rounded,
                    color: isDark ? Colors.white : AppColors.primary),
                onPressed: _showQuestionPalette,
              ),
          ],
        ),
        body: _isTestSubmitted
            ? _buildSubmittedView(isDark)
            : _questions.isEmpty
            ? Center(
          child: Text(
            'No questions available',
            style: TextStyle(color: secondaryTextColor),
          ),
        )
            : Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _buildQuestionView(
                isDark,
                cardColor,
                borderColor,
                textColor,
                secondaryTextColor,
              ),
            ),
            _buildBottomNavigation(
                isDark, textColor, borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final isLowTime = _remainingSeconds < 300;
    final timerColor = isLowTime ? AppColors.danger : AppColors.secondary;
    final timerBg = isLowTime
        ? AppColors.danger.withOpacity(0.1)
        : AppColors.secondary.withOpacity(0.1);
    final timerBorder = isLowTime
        ? AppColors.danger.withOpacity(0.3)
        : AppColors.secondary.withOpacity(0.3);
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : AppColors.background,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: timerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: timerBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: timerColor),
                const SizedBox(width: 6),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(bool isDark, Color cardColor, Color borderColor,
      Color textColor, Color secondaryTextColor) {
    final question = _questions[_currentQuestionIndex];
    final questionId = question['_id'] ?? '';
    final selectedOption = _getSelectedOption(questionId);
    final isMarked = _isQuestionMarked(questionId);
    final options = List.from(question['options'] ?? []);
    final marksColor = isDark ? Colors.white70 : AppColors.primary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${question['marks'] ?? 0} Marks',
                  style: TextStyle(
                    fontSize: 12,
                    color: marksColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (selectedOption.isNotEmpty)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _clearSelection(questionId),
                  icon: const Icon(Icons.clear_rounded,
                      size: 14, color: AppColors.danger),
                  label: const Text(
                    'Clear Selection',
                    style: TextStyle(fontSize: 12, color: AppColors.danger),
                  ),
                ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _toggleMarkQuestion(questionId),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isMarked
                        ? (isDark
                        ? const Color(0xFF2D1F0A)
                        : Colors.amber.shade50)
                        : cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color:
                        isMarked ? Colors.amber.shade700 : borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 15,
                        color: isMarked
                            ? Colors.amber.shade800
                            : (isDark ? Colors.white38 : AppColors.textMuted),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMarked ? 'Marked' : 'Mark',
                        style: TextStyle(
                          fontSize: 12,
                          color: isMarked
                              ? Colors.amber.shade800
                              : (isDark ? Colors.white38 : AppColors.textMuted),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              question['text'] ?? '',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(options.length, (index) {
            final option = options[index];
            final optionKey = option['key'] ?? '';
            final isSelected = selectedOption == optionKey;

            return _buildOptionCard(
              optionKey: optionKey,
              text: option['text'] ?? '',
              isSelected: isSelected,
              isDark: isDark,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
              onTap: () => _selectOption(questionId, optionKey),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String optionKey,
    required String text,
    required bool isSelected,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final primaryColor = AppColors.primary;
    final optionBg = isSelected ? primaryColor.withOpacity(0.08) : cardColor;
    final optionBorder = isSelected ? primaryColor : borderColor;
    final optionBorderWidth = isSelected ? 2.0 : 1.0;
    final optionTextColor = isSelected ? primaryColor : textColor;
    final optionWeight = isSelected ? FontWeight.w600 : FontWeight.normal;
    final circleBg = isSelected
        ? primaryColor
        : (isDark ? const Color(0xFF0A0A0F) : AppColors.bg);
    final circleBorder = isSelected ? primaryColor : borderColor;
    final circleTextColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white70 : AppColors.textSecondary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: optionBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: optionBorder, width: optionBorderWidth),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: primaryColor.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: circleBorder),
                  ),
                  child: Center(
                    child: Text(
                      optionKey,
                      style: TextStyle(
                        color: circleTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: optionTextColor,
                      fontWeight: optionWeight,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
      bool isDark, Color textColor, Color borderColor) {
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : AppColors.background;
    final btnBg = isLastQuestion ? AppColors.secondary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _currentQuestionIndex > 0
                    ? () {
                  HapticFeedback.lightImpact();
                  setState(() => _currentQuestionIndex--);
                }
                    : null,
                child: Text(
                  'Previous',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnBg,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (isLastQuestion) {
                    _submitTest();
                  } else {
                    setState(() => _currentQuestionIndex++);
                  }
                },
                child: Text(
                  isLastQuestion ? 'Submit Test' : 'Next Question',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedView(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;
    final circleBg = isDark
        ? const Color(0xFF1A3A1A)
        : AppColors.secondary.withOpacity(0.1);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 72,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Test Submitted Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You completed ${_getAnsweredCount()} out of ${_questions.length} questions.',
              style: TextStyle(fontSize: 14, color: secondaryTextColor),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isDark ? Colors.white : AppColors.primary,
                  foregroundColor:
                  isDark ? const Color(0xFF0A0A0F) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Home',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: isDark ? const Color(0xFFEF5350) : AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to load test attempt',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.primary,
                foregroundColor:
                isDark ? const Color(0xFF0A0A0F) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}