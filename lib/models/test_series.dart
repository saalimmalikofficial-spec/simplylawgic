// lib/models/test_series.dart

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

  // 🔥 Purchase / Access fields (series level)
  final bool purchased;
  final bool hasAccess;
  final bool unlocked;

  // 🔥 Extra counters
  final int attemptedCount;
  final int inProgressCount;
  final bool hasCompletedAttempt;

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
    required this.purchased,
    required this.hasAccess,
    required this.unlocked,
    required this.attemptedCount,
    required this.inProgressCount,
    required this.hasCompletedAttempt,
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
      purchased: json['purchased'] ?? false,
      hasAccess: json['hasAccess'] ?? false,
      unlocked: json['unlocked'] ?? false,
      attemptedCount: json['attemptedCount'] ?? 0,
      inProgressCount: json['inProgressCount'] ?? 0,
      hasCompletedAttempt: json['hasCompletedAttempt'] ?? false,
    );
  }

  static List<TestSeries> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TestSeries.fromJson(json)).toList();
  }

  // ============================================================
  // 🔥 SERIES LEVEL GETTERS
  // ============================================================

  /// Series free hai (poora pack free)
  bool get isSeriesFree => !isPaid;

  /// Series paid hai AND user ne purchase kiya
  bool get isSeriesPurchased => purchased || hasAccess || unlocked;

  /// Whether user can access the series overall
  bool get canAccessSeries {
    if (!isPaid) return true;
    return isSeriesPurchased;
  }

  /// Series locked hai (paid + not purchased)
  bool get isSeriesLocked => isPaid && !canAccessSeries;

  /// Display price
  String get displayPrice {
    if (!isPaid) return 'FREE';
    return '₹$priceAmount';
  }

  /// Whether user has any activity
  bool get hasActivity => attemptedCount > 0 || inProgressCount > 0;

  /// Actual test count from list
  int get actualTestCount => tests.isNotEmpty ? tests.length : testCount;

  /// 🔥 Kitne tests free hai iss series me
  int get freeTestCount => tests.where((t) => !t.isPaid).length;

  /// 🔥 Kitne tests paid hai iss series me
  int get paidTestCount => tests.where((t) => t.isPaid).length;

  /// 🔥 Whether series has any free test to try
  bool get hasFreeTest => tests.any((t) => !t.isPaid);

  // ============================================================
  // 🔥 MOST IMPORTANT: Test-level access resolver
  // ============================================================
  /// Ye decide karta hai ki particular test user ke liye accessible hai ya nahi.
  ///
  /// Rules (in order):
  /// 1. Agar series purchased / hasAccess → SAARE tests unlocked
  /// 2. Agar test free hai (isPaid == false) → accessible
  /// 3. Agar test ka individual `unlocked == true` → accessible
  /// 4. Warna locked
  bool isTestAccessible(Test test) {
    // Rule 1: Full series purchase → sab kuch khol do
    if (canAccessSeries) return true;

    // Rule 2: Free test
    if (!test.isPaid) return true;

    // Rule 3: Backend ne individually unlock kiya
    if (test.unlocked) return true;

    // Otherwise locked
    return false;
  }

  /// Same as above but for index (for ListView)
  bool isTestAccessibleAt(int index) {
    if (index < 0 || index >= tests.length) return false;
    return isTestAccessible(tests[index]);
  }

  // ============================================================
  // copyWith
  // ============================================================
  TestSeries copyWith({
    String? id,
    String? slug,
    String? title,
    String? description,
    String? coverImageUrl,
    List<String>? tags,
    String? packType,
    bool? isPaid,
    int? priceAmount,
    String? currency,
    String? status,
    String? publishedAt,
    String? subjectName,
    String? subjectCategory,
    String? subjectSubcategory,
    String? createdAt,
    String? updatedAt,
    int? testCount,
    String? seriesKind,
    String? examKey,
    String? examCategory,
    String? examSubcategory,
    List<Test>? tests,
    bool? purchased,
    bool? hasAccess,
    bool? unlocked,
    int? attemptedCount,
    int? inProgressCount,
    bool? hasCompletedAttempt,
  }) {
    return TestSeries(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      tags: tags ?? this.tags,
      packType: packType ?? this.packType,
      isPaid: isPaid ?? this.isPaid,
      priceAmount: priceAmount ?? this.priceAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
      subjectName: subjectName ?? this.subjectName,
      subjectCategory: subjectCategory ?? this.subjectCategory,
      subjectSubcategory: subjectSubcategory ?? this.subjectSubcategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testCount: testCount ?? this.testCount,
      seriesKind: seriesKind ?? this.seriesKind,
      examKey: examKey ?? this.examKey,
      examCategory: examCategory ?? this.examCategory,
      examSubcategory: examSubcategory ?? this.examSubcategory,
      tests: tests ?? this.tests,
      purchased: purchased ?? this.purchased,
      hasAccess: hasAccess ?? this.hasAccess,
      unlocked: unlocked ?? this.unlocked,
      attemptedCount: attemptedCount ?? this.attemptedCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      hasCompletedAttempt: hasCompletedAttempt ?? this.hasCompletedAttempt,
    );
  }
}

// ============================================================
// TEST MODEL
// ============================================================
class Test {
  final String id;
  final String title;
  final String instructions;
  final int durationMinutes;
  final int questionCount;
  final int totalMarks;
  final int marksPerCorrect;
  final double negativeMarksPerWrong;
  final bool shuffleQuestions;
  final bool isPaid;
  final String publishedAt;
  final int order;
  final List<String> tags;
  final bool unlocked;

  Test({
    required this.id,
    required this.title,
    required this.instructions,
    required this.durationMinutes,
    required this.questionCount,
    required this.totalMarks,
    required this.marksPerCorrect,
    required this.negativeMarksPerWrong,
    required this.shuffleQuestions,
    required this.isPaid,
    required this.publishedAt,
    required this.order,
    required this.tags,
    required this.unlocked,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      instructions: json['instructions'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      questionCount: json['questionCount'] ?? 0,
      totalMarks: json['totalMarks'] ?? 0,
      marksPerCorrect: json['marksPerCorrect'] ?? 0,
      negativeMarksPerWrong:
      (json['negativeMarksPerWrong'] as num?)?.toDouble() ?? 0.0,
      shuffleQuestions: json['shuffleQuestions'] ?? false,
      isPaid: json['isPaid'] ?? false,
      publishedAt: json['publishedAt'] ?? '',
      order: json['order'] ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      unlocked: json['unlocked'] ?? false,
    );
  }

  // ============================================================
  // 🔥 TEST LEVEL GETTERS (ye sirf test-specific info batate hai)
  // ============================================================

  /// Test free hai
  bool get isFree => !isPaid;

  /// Backend ne individually ye test unlock kiya hai
  bool get isUnlockedByBackend => unlocked;

  /// Display duration
  String get displayDuration => '$durationMinutes min';

  /// Display marks
  String get displayMarksInfo =>
      '+$marksPerCorrect / -${negativeMarksPerWrong.toStringAsFixed(0)}';

  String get displayQuestionCount => '$questionCount Qs';
  String get displayTotalMarks => '$totalMarks Marks';

  /// ⚠️ NOTE: Ye getter series purchase ka nahi jaanta.
  /// Locked state check karne ke liye hamesha
  /// `series.isTestAccessible(test)` use karo.
  bool get isLockedWithoutSeriesContext => isPaid && !unlocked;

  Test copyWith({
    String? id,
    String? title,
    String? instructions,
    int? durationMinutes,
    int? questionCount,
    int? totalMarks,
    int? marksPerCorrect,
    double? negativeMarksPerWrong,
    bool? shuffleQuestions,
    bool? isPaid,
    String? publishedAt,
    int? order,
    List<String>? tags,
    bool? unlocked,
  }) {
    return Test(
      id: id ?? this.id,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      questionCount: questionCount ?? this.questionCount,
      totalMarks: totalMarks ?? this.totalMarks,
      marksPerCorrect: marksPerCorrect ?? this.marksPerCorrect,
      negativeMarksPerWrong:
      negativeMarksPerWrong ?? this.negativeMarksPerWrong,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      isPaid: isPaid ?? this.isPaid,
      publishedAt: publishedAt ?? this.publishedAt,
      order: order ?? this.order,
      tags: tags ?? this.tags,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}