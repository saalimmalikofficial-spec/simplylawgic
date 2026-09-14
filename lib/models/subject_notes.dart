// lib/models/subject_notes.dart
class SubjectNotes {
  final String id;
  final String slug;
  final String subjectName;
  final String displayTitle;
  final String sectionLabel;
  final String tagline;
  final String publishedAt;
  final String createdAt;
  final String updatedAt;
  final String heroBookImageUrl;
  final String subjectCategory;
  final String heroBannerUrl;
  final List<Block> blocks;
  final String status;

  SubjectNotes({
    required this.id,
    required this.slug,
    required this.subjectName,
    required this.displayTitle,
    required this.sectionLabel,
    required this.tagline,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.heroBookImageUrl,
    required this.subjectCategory,
    required this.heroBannerUrl,
    required this.blocks,
    required this.status,
  });

  factory SubjectNotes.fromJson(Map<String, dynamic> json) {
    return SubjectNotes(
      id: json['_id'] ?? '',
      slug: json['slug'] ?? '',
      subjectName: json['subjectName'] ?? '',
      displayTitle: json['displayTitle'] ?? '',
      sectionLabel: json['sectionLabel'] ?? '',
      tagline: json['tagline'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      heroBookImageUrl: json['heroBookImageUrl'] ?? '',
      subjectCategory: json['subjectCategory'] ?? '',
      heroBannerUrl: json['heroBannerUrl'] ?? '',
      status: json['status'] ?? '',
      blocks: json['blocks'] != null
          ? List<Block>.from(json['blocks'].map((x) => Block.fromJson(x)))
          : [],
    );
  }

  static List<SubjectNotes> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SubjectNotes.fromJson(json)).toList();
  }

  /// 👇 Pehla pdf_purchase block nikaalo (purchase CTA ke liye)
  Block? get purchaseBlock {
    try {
      return blocks.firstWhere((b) => b.type == 'pdf_purchase');
    } catch (_) {
      return null;
    }
  }

  /// 👇 Preview blocks — purchase block se pehle ke blocks
  List<Block> get previewBlocks {
    final idx = blocks.indexWhere((b) => b.type == 'pdf_purchase');
    if (idx == -1) return blocks;
    return blocks.sublist(0, idx);
  }

  /// 👇 Locked blocks — purchase block ke baad ke blocks
  List<Block> get lockedBlocks {
    final idx = blocks.indexWhere((b) => b.type == 'pdf_purchase');
    if (idx == -1) return [];
    return blocks.sublist(idx + 1);
  }
}

class Block {
  final String id;
  final int order;
  final String type;
  final Payload payload;

  Block({
    required this.id,
    required this.order,
    required this.type,
    required this.payload,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['_id'] ?? '',
      order: json['order'] ?? 0,
      type: json['type'] ?? '',
      payload: Payload.fromJson(json['payload'] ?? {}),
    );
  }
}

class Payload {
  final String text;
  final String? format;
  final int? level;
  final String? textSize;
  final List<String>? items;

  // 👇 pdf_purchase fields
  final String? title;
  final String? description;
  final num? priceAmount;
  final String? currency;
  final bool? viewOnlyInBrowser;
  final bool? allowStudentDownload;
  final String? pdfOriginalName;

  // 👇 image carousel fields
  final String? layout;
  final String? url;
  final String? alt;
  final String? caption;
  final List<Map<String, dynamic>>? images;

  Payload({
    required this.text,
    this.format,
    this.level,
    this.textSize,
    this.items,
    this.title,
    this.description,
    this.priceAmount,
    this.currency,
    this.viewOnlyInBrowser,
    this.allowStudentDownload,
    this.pdfOriginalName,
    this.layout,
    this.url,
    this.alt,
    this.caption,
    this.images,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      text: json['text'] ?? '',
      format: json['format'],
      level: json['level'],
      textSize: json['textSize'],
      items: json['items'] != null ? List<String>.from(json['items']) : null,
      title: json['title'],
      description: json['description'],
      priceAmount: json['priceAmount'] as num?,
      currency: json['currency'],
      viewOnlyInBrowser: json['viewOnlyInBrowser'] as bool?,
      allowStudentDownload: json['allowStudentDownload'] as bool?,
      pdfOriginalName: json['pdfOriginalName'],
      layout: json['layout'],
      url: json['url'],
      alt: json['alt'],
      caption: json['caption'],
      images: json['images'] != null
          ? List<Map<String, dynamic>>.from(
        (json['images'] as List).map((e) => Map<String, dynamic>.from(e)),
      )
          : null,
    );
  }
}