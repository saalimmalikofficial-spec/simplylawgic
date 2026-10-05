// lib/models/attempt_report_model.dart

class AttemptReport {
  final String attemptId;
  final String status;
  final int score;
  final int maxScore;
  final double percentage;
  final double accuracy;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int timeTakenSeconds;
  final ReportSeries? series;
  final ReportTest? test;
  final List<ReportQuestion> breakdown;

  AttemptReport({
    required this.attemptId,
    required this.status,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.accuracy,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    this.startedAt,
    this.submittedAt,
    required this.timeTakenSeconds,
    this.series,
    this.test,
    required this.breakdown,
  });

  bool get isSubmitted => status == 'submitted';

  String get formattedTimeTaken {
    final h = timeTakenSeconds ~/ 3600;
    final m = (timeTakenSeconds % 3600) ~/ 60;
    final s = timeTakenSeconds % 60;
    if (h > 0) {
      return '${h}h ${m}m ${s}s';
    }
    return '${m}m ${s}s';
  }

  factory AttemptReport.fromJson(Map<String, dynamic> json) {
    return AttemptReport(
      attemptId: json['attemptId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      skippedCount: (json['skippedCount'] as num?)?.toInt() ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      timeTakenSeconds: (json['timeTakenSeconds'] as num?)?.toInt() ?? 0,
      series: json['series'] is Map<String, dynamic>
          ? ReportSeries.fromJson(json['series'])
          : null,
      test: json['test'] is Map<String, dynamic>
          ? ReportTest.fromJson(json['test'])
          : null,
      breakdown: (json['breakdown'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map((e) => ReportQuestion.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ReportSeries {
  final String slug;
  final String title;

  ReportSeries({required this.slug, required this.title});

  factory ReportSeries.fromJson(Map<String, dynamic> json) {
    return ReportSeries(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

class ReportTest {
  final String id;
  final String title;
  final int durationMinutes;
  final int negativeMarksPerWrong;

  ReportTest({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.negativeMarksPerWrong,
  });

  factory ReportTest.fromJson(Map<String, dynamic> json) {
    return ReportTest(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      negativeMarksPerWrong:
      (json['negativeMarksPerWrong'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReportQuestion {
  final String questionId;
  final String selectedOption;
  final String correctOption;
  final String result;
  final int marks;
  final String explanation;
  final String explanationFileUrl;
  final String explanationFileKind;
  final String explanationFileName;
  final String text;
  final List<ReportOption> options;
  final String topic;
  final String subjectTag;
  final bool bookmarked;

  ReportQuestion({
    required this.questionId,
    required this.selectedOption,
    required this.correctOption,
    required this.result,
    required this.marks,
    required this.explanation,
    required this.explanationFileUrl,
    required this.explanationFileKind,
    required this.explanationFileName,
    required this.text,
    required this.options,
    required this.topic,
    required this.subjectTag,
    this.bookmarked = false, // ✅ default
  });

  bool get isCorrect => result == 'correct';
  bool get isWrong => result == 'wrong';
  bool get isSkipped => result == 'skipped';

  factory ReportQuestion.fromJson(Map<String, dynamic> json) {
    return ReportQuestion(
      questionId: json['questionId']?.toString() ?? '',
      selectedOption: json['selectedOption']?.toString() ?? '',
      correctOption: json['correctOption']?.toString() ?? '',
      result: json['result']?.toString() ?? 'skipped',
      marks: (json['marks'] as num?)?.toInt() ?? 0,
      explanation: json['explanation']?.toString() ?? '',
      explanationFileUrl: json['explanationFileUrl']?.toString() ?? '',
      explanationFileKind: json['explanationFileKind']?.toString() ?? '',
      explanationFileName: json['explanationFileName']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map((e) => ReportOption.fromJson(e))
          .toList() ??
          [],
      topic: json['topic']?.toString() ?? '',
      subjectTag: json['subjectTag']?.toString() ?? '',
      bookmarked: json['bookmarked'] as bool? ?? false,
    );
  }
}

class ReportOption {
  final String key;
  final String text;

  ReportOption({required this.key, required this.text});

  factory ReportOption.fromJson(Map<String, dynamic> json) {
    return ReportOption(
      key: json['key']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}