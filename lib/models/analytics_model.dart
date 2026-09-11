// lib/models/analytics_model.dart
class AnalyticsData {
  final Summary summary;
  final QuestionBreakdown questionBreakdown;
  final List<ScoreTrend> scoreTrend;
  final List<CategoryPerformance> byCategory;
  final TopicAnalysis byTopic;
  final List<RetakeProgress> retakeProgress;
  final List<Insight> insights;
  final List<RecentAttempt> recentAttempts;
  final List<SeriesPerformance> bySeries;

  AnalyticsData({
    required this.summary,
    required this.questionBreakdown,
    required this.scoreTrend,
    required this.byCategory,
    required this.byTopic,
    required this.retakeProgress,
    required this.insights,
    required this.recentAttempts,
    required this.bySeries,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      summary: Summary.fromJson(json['summary']),
      questionBreakdown: QuestionBreakdown.fromJson(json['questionBreakdown']),
      scoreTrend: (json['scoreTrend'] as List)
          .map((e) => ScoreTrend.fromJson(e))
          .toList(),
      byCategory: (json['byCategory'] as List)
          .map((e) => CategoryPerformance.fromJson(e))
          .toList(),
      byTopic: TopicAnalysis.fromJson(json['byTopic']),
      retakeProgress: (json['retakeProgress'] as List)
          .map((e) => RetakeProgress.fromJson(e))
          .toList(),
      insights: (json['insights'] as List)
          .map((e) => Insight.fromJson(e))
          .toList(),
      recentAttempts: (json['recentAttempts'] as List)
          .map((e) => RecentAttempt.fromJson(e))
          .toList(),
      bySeries: (json['bySeries'] as List)
          .map((e) => SeriesPerformance.fromJson(e))
          .toList(),
    );
  }
}

class Summary {
  final int submittedAttemptsCount;
  final int totalScore;
  final int totalMaxScore;
  final double totalPercentage;
  final double averagePercentage;
  final double bestPercentage;
  final int totalCorrect;
  final int totalWrong;
  final int totalSkipped;
  final double accuracy;
  final int testsThisWeek;
  final int testsThisMonth;
  final int studyStreakDays;
  final double averageTimeUsedPercent;
  final double averageTimeTakenMinutes;
  final int bookmarkCount;

  Summary({
    required this.submittedAttemptsCount,
    required this.totalScore,
    required this.totalMaxScore,
    required this.totalPercentage,
    required this.averagePercentage,
    required this.bestPercentage,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalSkipped,
    required this.accuracy,
    required this.testsThisWeek,
    required this.testsThisMonth,
    required this.studyStreakDays,
    required this.averageTimeUsedPercent,
    required this.averageTimeTakenMinutes,
    required this.bookmarkCount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      submittedAttemptsCount: json['submittedAttemptsCount'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      totalMaxScore: json['totalMaxScore'] ?? 0,
      totalPercentage: (json['totalPercentage'] ?? 0).toDouble(),
      averagePercentage: (json['averagePercentage'] ?? 0).toDouble(),
      bestPercentage: (json['bestPercentage'] ?? 0).toDouble(),
      totalCorrect: json['totalCorrect'] ?? 0,
      totalWrong: json['totalWrong'] ?? 0,
      totalSkipped: json['totalSkipped'] ?? 0,
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      testsThisWeek: json['testsThisWeek'] ?? 0,
      testsThisMonth: json['testsThisMonth'] ?? 0,
      studyStreakDays: json['studyStreakDays'] ?? 0,
      averageTimeUsedPercent: (json['averageTimeUsedPercent'] ?? 0).toDouble(),
      averageTimeTakenMinutes: (json['averageTimeTakenMinutes'] ?? 0).toDouble(),
      bookmarkCount: json['bookmarkCount'] ?? 0,
    );
  }
}

class QuestionBreakdown {
  final int correct;
  final int wrong;
  final int skipped;
  final int total;

  QuestionBreakdown({
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.total,
  });

  factory QuestionBreakdown.fromJson(Map<String, dynamic> json) {
    return QuestionBreakdown(
      correct: json['correct'] ?? 0,
      wrong: json['wrong'] ?? 0,
      skipped: json['skipped'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class ScoreTrend {
  final String attemptId;
  final DateTime date;
  final double percentage;
  final String testTitle;
  final String seriesTitle;

  ScoreTrend({
    required this.attemptId,
    required this.date,
    required this.percentage,
    required this.testTitle,
    required this.seriesTitle,
  });

  factory ScoreTrend.fromJson(Map<String, dynamic> json) {
    return ScoreTrend(
      attemptId: json['attemptId'] ?? '',
      date: DateTime.parse(json['date']),
      percentage: (json['percentage'] ?? 0).toDouble(),
      testTitle: json['testTitle'] ?? '',
      seriesTitle: json['seriesTitle'] ?? '',
    );
  }
}

class CategoryPerformance {
  final String label;
  final String seriesKind;
  final int attemptsCount;
  final int totalCorrect;
  final int totalWrong;
  final int totalSkipped;
  final int totalScore;
  final int totalMaxScore;
  final double percentage;
  final double accuracy;

  CategoryPerformance({
    required this.label,
    required this.seriesKind,
    required this.attemptsCount,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalSkipped,
    required this.totalScore,
    required this.totalMaxScore,
    required this.percentage,
    required this.accuracy,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      label: json['label'] ?? '',
      seriesKind: json['seriesKind'] ?? '',
      attemptsCount: json['attemptsCount'] ?? 0,
      totalCorrect: json['totalCorrect'] ?? 0,
      totalWrong: json['totalWrong'] ?? 0,
      totalSkipped: json['totalSkipped'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      totalMaxScore: json['totalMaxScore'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
    );
  }
}

class TopicAnalysis {
  final List<dynamic> topics;
  final List<dynamic> weaknesses;
  final List<dynamic> strengths;

  TopicAnalysis({
    required this.topics,
    required this.weaknesses,
    required this.strengths,
  });

  factory TopicAnalysis.fromJson(Map<String, dynamic> json) {
    return TopicAnalysis(
      topics: json['topics'] ?? [],
      weaknesses: json['weaknesses'] ?? [],
      strengths: json['strengths'] ?? [],
    );
  }
}

class RetakeProgress {
  final String testId;
  final String testTitle;
  final String seriesSlug;
  final String seriesTitle;
  final int attemptsCount;
  final double firstPercentage;
  final double latestPercentage;
  final double improvement;
  final bool improved;

  RetakeProgress({
    required this.testId,
    required this.testTitle,
    required this.seriesSlug,
    required this.seriesTitle,
    required this.attemptsCount,
    required this.firstPercentage,
    required this.latestPercentage,
    required this.improvement,
    required this.improved,
  });

  factory RetakeProgress.fromJson(Map<String, dynamic> json) {
    return RetakeProgress(
      testId: json['testId'] ?? '',
      testTitle: json['testTitle'] ?? '',
      seriesSlug: json['seriesSlug'] ?? '',
      seriesTitle: json['seriesTitle'] ?? '',
      attemptsCount: json['attemptsCount'] ?? 0,
      firstPercentage: (json['firstPercentage'] ?? 0).toDouble(),
      latestPercentage: (json['latestPercentage'] ?? 0).toDouble(),
      improvement: (json['improvement'] ?? 0).toDouble(),
      improved: json['improved'] ?? false,
    );
  }
}

class Insight {
  final String type;
  final String title;
  final String message;

  Insight({
    required this.type,
    required this.title,
    required this.message,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class RecentAttempt {
  final String attemptId;
  final String testId;
  final String status;
  final int score;
  final int maxScore;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int totalQuestions;
  final double percentage;
  final double accuracy;
  final DateTime startedAt;
  final DateTime submittedAt;
  final int timeTakenSeconds;
  final double timeUsedPercent;
  final TestInfo test;
  final SeriesInfo series;

  RecentAttempt({
    required this.attemptId,
    required this.testId,
    required this.status,
    required this.score,
    required this.maxScore,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.totalQuestions,
    required this.percentage,
    required this.accuracy,
    required this.startedAt,
    required this.submittedAt,
    required this.timeTakenSeconds,
    required this.timeUsedPercent,
    required this.test,
    required this.series,
  });

  factory RecentAttempt.fromJson(Map<String, dynamic> json) {
    return RecentAttempt(
      attemptId: json['attemptId'] ?? '',
      testId: json['testId'] ?? '',
      status: json['status'] ?? '',
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
      skippedCount: json['skippedCount'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      startedAt: DateTime.parse(json['startedAt']),
      submittedAt: DateTime.parse(json['submittedAt']),
      timeTakenSeconds: json['timeTakenSeconds'] ?? 0,
      timeUsedPercent: (json['timeUsedPercent'] ?? 0).toDouble(),
      test: TestInfo.fromJson(json['test']),
      series: SeriesInfo.fromJson(json['series']),
    );
  }
}

class TestInfo {
  final String id;
  final String title;
  final int durationMinutes;
  final String seriesKind;

  TestInfo({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.seriesKind,
  });

  factory TestInfo.fromJson(Map<String, dynamic> json) {
    return TestInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      seriesKind: json['seriesKind'] ?? '',
    );
  }
}

class SeriesInfo {
  final String id;
  final String slug;
  final String title;
  final String coverImageUrl;
  final String seriesKind;
  final String subjectName;
  final String subjectCategory;
  final dynamic examKey;
  final dynamic examCategory;

  SeriesInfo({
    required this.id,
    required this.slug,
    required this.title,
    required this.coverImageUrl,
    required this.seriesKind,
    required this.subjectName,
    required this.subjectCategory,
    this.examKey,
    this.examCategory,
  });

  factory SeriesInfo.fromJson(Map<String, dynamic> json) {
    return SeriesInfo(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      seriesKind: json['seriesKind'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectCategory: json['subjectCategory'] ?? '',
      examKey: json['examKey'],
      examCategory: json['examCategory'],
    );
  }
}

class SeriesPerformance {
  final String seriesSlug;
  final String seriesTitle;
  final String coverImageUrl;
  final String seriesKind;
  final int attemptsCount;
  final int totalScore;
  final int totalMaxScore;
  final double bestPercentage;
  final DateTime lastSubmittedAt;
  final double percentage;

  SeriesPerformance({
    required this.seriesSlug,
    required this.seriesTitle,
    required this.coverImageUrl,
    required this.seriesKind,
    required this.attemptsCount,
    required this.totalScore,
    required this.totalMaxScore,
    required this.bestPercentage,
    required this.lastSubmittedAt,
    required this.percentage,
  });

  factory SeriesPerformance.fromJson(Map<String, dynamic> json) {
    return SeriesPerformance(
      seriesSlug: json['seriesSlug'] ?? '',
      seriesTitle: json['seriesTitle'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      seriesKind: json['seriesKind'] ?? '',
      attemptsCount: json['attemptsCount'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      totalMaxScore: json['totalMaxScore'] ?? 0,
      bestPercentage: (json['bestPercentage'] ?? 0).toDouble(),
      lastSubmittedAt: DateTime.parse(json['lastSubmittedAt']),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}