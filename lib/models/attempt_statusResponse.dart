// lib/models/attempt_status_response.dart
import 'attempt_report_model.dart';

// ============================================================
// ATTEMPT STATUS RESPONSE
// ============================================================
class AttemptStatusResponse {
  final String phase;
  final String? attemptId;
  final String? status;
  final int score;
  final int maxScore;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final DateTime? submittedAt;

  // Multi-attempt fields
  final bool canRetake;
  final int attemptCount;
  final int reattemptCount;
  final List<PreviousAttempt> previousAttempts;

  final AttemptSeriesInfo? series;
  final AttemptTestInfo? test;
  final List<ReportQuestion> breakdown;

  AttemptStatusResponse({
    required this.phase,
    this.attemptId,
    this.status,
    required this.score,
    required this.maxScore,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    this.submittedAt,
    this.canRetake = false,
    this.attemptCount = 0,
    this.reattemptCount = 0,
    this.previousAttempts = const [],
    this.series,
    this.test,
    required this.breakdown,
  });

  // ✅ Dono formats accept karo (underscore + hyphen)
  bool get isCompleted =>
      phase == 'completed' ||
          status == 'completed' ||
          status == 'submitted';

  bool get isSubmitted => status == 'submitted' || status == 'completed';

  bool get isInProgress =>
      phase == 'in_progress' ||
          phase == 'in-progress' ||
          status == 'in_progress' ||
          status == 'in-progress';

  bool get hasMultipleAttempts => previousAttempts.length > 1;

  double get percentage => maxScore == 0 ? 0 : (score / maxScore) * 100;

  factory AttemptStatusResponse.fromJson(Map<String, dynamic> json) {
    return AttemptStatusResponse(
      phase: json['phase']?.toString() ?? 'not-started',
      attemptId: json['attemptId']?.toString(),
      status: json['status']?.toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      skippedCount: (json['skippedCount'] as num?)?.toInt() ?? 0,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      canRetake: json['canRetake'] == true,
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      reattemptCount: (json['reattemptCount'] as num?)?.toInt() ?? 0,
      previousAttempts: (json['previousAttempts'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map((e) => PreviousAttempt.fromJson(e))
          .toList() ??
          [],
      series: json['series'] is Map<String, dynamic>
          ? AttemptSeriesInfo.fromJson(json['series'])
          : null,
      test: json['test'] is Map<String, dynamic>
          ? AttemptTestInfo.fromJson(json['test'])
          : null,
      breakdown: (json['breakdown'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map((e) => ReportQuestion.fromJson(e))
          .toList() ??
          [],
    );
  }
}

// ============================================================
// PREVIOUS ATTEMPT
// ============================================================
class PreviousAttempt {
  final String attemptId;
  final int score;
  final int maxScore;
  final DateTime? submittedAt;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;

  PreviousAttempt({
    required this.attemptId,
    required this.score,
    required this.maxScore,
    this.submittedAt,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
  });

  double get percentage => maxScore == 0 ? 0 : (score / maxScore) * 100;

  String get grade {
    final p = percentage;
    if (p >= 70) return 'Great';
    if (p >= 40) return 'Average';
    return 'Needs Work';
  }

  factory PreviousAttempt.fromJson(Map<String, dynamic> json) {
    return PreviousAttempt(
      attemptId: json['attemptId']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      skippedCount: (json['skippedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============================================================
// ATTEMPT SERIES INFO
// ============================================================
class AttemptSeriesInfo {
  final String slug;
  final String title;

  AttemptSeriesInfo({required this.slug, required this.title});

  factory AttemptSeriesInfo.fromJson(Map<String, dynamic> json) {
    return AttemptSeriesInfo(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

// ============================================================
// ATTEMPT TEST INFO
// ============================================================
class AttemptTestInfo {
  final String? id;
  final String title;
  final int durationMinutes;
  final int negativeMarksPerWrong;

  AttemptTestInfo({
    this.id,
    required this.title,
    required this.durationMinutes,
    required this.negativeMarksPerWrong,
  });

  factory AttemptTestInfo.fromJson(Map<String, dynamic> json) {
    return AttemptTestInfo(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      negativeMarksPerWrong:
      (json['negativeMarksPerWrong'] as num?)?.toInt() ?? 0,
    );
  }
}