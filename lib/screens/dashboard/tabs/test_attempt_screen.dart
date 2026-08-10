// lib/screens/tests/test_attempt_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simplylawgic/services/api_service.dart';

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

  Future<void> _startTest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isTestSubmitted = false;
    });

    try {
      final data = await _apiService.startTestAttempt(
        widget.seriesSlug,
        widget.testId,
      );

      // Check if test is already submitted
      if (data['status'] == 'submitted' || data['status'] == 'completed') {
        setState(() {
          _isTestSubmitted = true;
          _errorMessage = 'This test has already been submitted.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _attemptData = data;
        _questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        _answers = List<Map<String, dynamic>>.from(data['answers'] ?? []);
        _markedQuestions = List<String>.from(data['markedQuestionIds'] ?? []);
        _remainingSeconds = data['remainingSeconds'] ?? 0;
        _isLoading = false;
      });

      _startTimer();
      _startAutoSync();
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      if (errorMsg.contains('already submitted') || errorMsg.contains('submitted')) {
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      print('Sync error: $e');
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
        content: Text('⏰ Time\'s up! Auto-submitting test...'),
        backgroundColor: Colors.red,
      ),
    );
    _submitTestAttempt();
  }

  void _selectOption(String questionId, String optionKey) {
    if (_isTestSubmitted) return;

    setState(() {
      final index = _answers.indexWhere((a) => a['questionId'] == questionId);
      if (index != -1) {
        _answers[index]['selectedOption'] = optionKey;
      }
    });
    _submitAnswer(questionId, optionKey);
  }

  Future<void> _submitAnswer(String questionId, String optionKey) async {
    if (_isTestSubmitted) return;

    try {
      final attemptId = _attemptData?['attemptId'] ?? '';
      await _apiService.submitAnswer(attemptId, questionId, optionKey);
    } catch (e) {
      // Handle error silently
    }
  }

  void _toggleMarkQuestion(String questionId) {
    if (_isTestSubmitted) return;

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
      // Handle error
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
    return _answers.where((a) => a['selectedOption']?.isNotEmpty ?? false).length;
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _submitTest() {
    if (_isTestSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This test has already been submitted.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final answeredCount = _getAnsweredCount();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test'),
        content: Text(
          'You have answered $answeredCount out of ${_questions.length} questions.\n\nAre you sure you want to submit?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
            ),
            onPressed: () {
              Navigator.pop(context);
              _submitTestAttempt();
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _submitTestAttempt() async {
    if (_isTestSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test already submitted.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
            content: Text('✅ Test submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      if (errorMsg.contains('already submitted')) {
        setState(() {
          _isTestSubmitted = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test already submitted.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isTestSubmitted) {
          return true;
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Test'),
            content: const Text('Are you sure you want to exit? Your progress will be saved.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue Test'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            _isTestSubmitted ? 'Test Submitted' : widget.testTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          actions: [
            if (_isSyncing)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                  ),
                ),
              ),
            if (!_isTestSubmitted)
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                onPressed: _submitTest,
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isTestSubmitted
            ? _buildSubmittedView()
            : _errorMessage != null
            ? _buildErrorView()
            : _questions.isEmpty
            ? _buildEmptyView()
            : Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildQuestionView(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade50,
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '✅ Test Submitted!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your test has been submitted successfully.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You answered ${_getAnsweredCount()} out of ${_questions.length} questions.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text('No questions available'),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _remainingSeconds < 300 ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _remainingSeconds < 300 ? Colors.red.shade200 : Colors.green.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 18,
                  color: _remainingSeconds < 300 ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _remainingSeconds < 300 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${_currentQuestionIndex + 1}/${_questions.length}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          if (_markedQuestions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '📌 ${_markedQuestions.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions[_currentQuestionIndex];
    final questionId = question['_id'] ?? '';
    final selectedOption = _getSelectedOption(questionId);
    final isMarked = _isQuestionMarked(questionId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Q${_currentQuestionIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  '${question['marks'] ?? 0} marks',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleMarkQuestion(questionId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isMarked ? Colors.orange.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMarked ? Colors.orange : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: isMarked ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMarked ? 'Marked' : 'Mark',
                        style: TextStyle(
                          fontSize: 12,
                          color: isMarked ? Colors.orange : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question['text'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            (question['options'] as List).length,
                (index) {
              final option = question['options'][index];
              final optionKey = option['key'] ?? '';
              final isSelected = selectedOption == optionKey;

              return _buildOptionTile(
                optionKey: optionKey,
                text: option['text'] ?? '',
                isSelected: isSelected,
                onTap: () => _selectOption(questionId, optionKey),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isQuestionAnswered(questionId)
                  ? Colors.green.shade50
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isQuestionAnswered(questionId)
                    ? Colors.green.shade200
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isQuestionAnswered(questionId)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _isQuestionAnswered(questionId)
                      ? Colors.green
                      : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _isQuestionAnswered(questionId)
                      ? 'Answered'
                      : 'Not Answered',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isQuestionAnswered(questionId)
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String optionKey,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  optionKey,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF6C5CE7) : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6C5CE7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (_isTestSubmitted) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Go Back',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _currentQuestionIndex == _questions.length - 1
                ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _submitTest,
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            )
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _goToNextQuestion,
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}