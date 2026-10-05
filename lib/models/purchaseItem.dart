// purchase_models.dart

class PurchaseItem {
  final String id;
  final String type;
  final String kind;
  final String subtype;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int amount;
  final String currency;
  final String amountLabel;
  final DateTime purchasedAt;
  final String productId;
  final String slug;
  final String accessToken;
  final String? noteId;
  final String? testSeriesId;
  final String? blockId;
  final bool purchased;
  final bool hasAccess;
  final bool unlocked;
  final String href;
  final String? accessPath;
  final String? streamPath;
  final String? streamUrl;

  PurchaseItem({
    required this.id,
    required this.type,
    required this.kind,
    required this.subtype,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.amount,
    required this.currency,
    required this.amountLabel,
    required this.purchasedAt,
    required this.productId,
    required this.slug,
    required this.accessToken,
    this.noteId,
    this.testSeriesId,
    this.blockId,
    required this.purchased,
    required this.hasAccess,
    required this.unlocked,
    required this.href,
    this.accessPath,
    this.streamPath,
    this.streamUrl,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      kind: json['kind'] ?? '',
      subtype: json['subtype'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      amountLabel: json['amountLabel'] ?? '',
      purchasedAt:
      DateTime.tryParse(json['purchasedAt'] ?? '') ?? DateTime.now(),
      productId: json['productId'] ?? '',
      slug: json['slug'] ?? '',
      accessToken: json['accessToken'] ?? '',
      noteId: json['noteId'],
      testSeriesId: json['testSeriesId'],
      blockId: json['blockId'],
      purchased: json['purchased'] ?? false,
      hasAccess: json['hasAccess'] ?? false,
      unlocked: json['unlocked'] ?? false,
      href: json['href'] ?? '',
      accessPath: json['accessPath'],
      streamPath: json['streamPath'],
      streamUrl: json['streamUrl'],
    );
  }

  bool get isTestSeries => type == 'test-series';
  bool get isNotes => type == 'notes';
}

class PurchasesResponse {
  final List<PurchaseItem> items;
  final PurchaseCounts counts;

  PurchasesResponse({required this.items, required this.counts});

  factory PurchasesResponse.fromJson(Map<String, dynamic> json) {
    return PurchasesResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      counts: PurchaseCounts.fromJson(json['counts'] ?? {}),
    );
  }
}

class PurchaseCounts {
  final int notes;
  final int tests;
  final int testSeries;
  final int currentAffairs;
  final int total;

  PurchaseCounts({
    required this.notes,
    required this.tests,
    required this.testSeries,
    required this.currentAffairs,
    required this.total,
  });

  factory PurchaseCounts.fromJson(Map<String, dynamic> json) {
    return PurchaseCounts(
      notes: json['notes'] ?? 0,
      tests: json['tests'] ?? 0,
      testSeries: json['testSeries'] ?? 0,
      currentAffairs: json['currentAffairs'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}