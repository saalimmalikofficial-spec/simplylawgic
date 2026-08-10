// lib/models/test_series.dart (Update with tests)
class TestSeries {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String coverImageUrl;
  final List<String> tags;
  final String packType;
  final bool isPaid;
  final int priceAmount;
  final String currency;
  final String status;
  final String publishedAt;
  final String subjectName;
  final String subjectCategory;
  final String subjectSubcategory;
  final String createdAt;
  final String updatedAt;
  final int testCount;
  final String seriesKind;
  final String examKey;
  final String examCategory;
  final String examSubcategory;
  final List<Test> tests;

  TestSeries({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.tags,
    required this.packType,
    required this.isPaid,
    required this.priceAmount,
    required this.currency,
    required this.status,
    required this.publishedAt,
    required this.subjectName,
    required this.subjectCategory,
    required this.subjectSubcategory,
    required this.createdAt,
    required this.updatedAt,
    required this.testCount,
    required this.seriesKind,
    required this.examKey,
    required this.examCategory,
    required this.examSubcategory,
    required this.tests,
  });

  factory TestSeries.fromJson(Map<String, dynamic> json) {
    return TestSeries(
      id: json['_id'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      packType: json['packType'] ?? '',
      isPaid: json['isPaid'] ?? false,
      priceAmount: json['priceAmount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectCategory: json['subjectCategory'] ?? '',
      subjectSubcategory: json['subjectSubcategory'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      testCount: json['testCount'] ?? 0,
      seriesKind: json['seriesKind'] ?? '',
      examKey: json['examKey'] ?? '',
      examCategory: json['examCategory'] ?? '',
      examSubcategory: json['examSubcategory'] ?? '',
      tests: json['tests'] != null
          ? List<Test>.from(json['tests'].map((x) => Test.fromJson(x)))
          : [],
    );
  }

  static List<TestSeries> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TestSeries.fromJson(json)).toList();
  }
}

class Test {
  final String id;
  final String title;
  final String instructions;
  final int durationMinutes;
  final int totalMarks;
  final double negativeMarksPerWrong;
  final bool shuffleQuestions;
  final int questionCount;
  final String publishedAt;
  final int order;
  final List<String> tags;

  Test({
    required this.id,
    required this.title,
    required this.instructions,
    required this.durationMinutes,
    required this.totalMarks,
    required this.negativeMarksPerWrong,
    required this.shuffleQuestions,
    required this.questionCount,
    required this.publishedAt,
    required this.order,
    required this.tags,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      instructions: json['instructions'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      totalMarks: json['totalMarks'] ?? 0,
      negativeMarksPerWrong: json['negativeMarksPerWrong']?.toDouble() ?? 0.0,
      shuffleQuestions: json['shuffleQuestions'] ?? false,
      questionCount: json['questionCount'] ?? 0,
      publishedAt: json['publishedAt'] ?? '',
      order: json['order'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}