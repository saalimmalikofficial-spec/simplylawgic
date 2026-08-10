// lib/models/subject_notes.dart (Update with full model)
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

  Payload({
    required this.text,
    this.format,
    this.level,
    this.textSize,
    this.items,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      text: json['text'] ?? '',
      format: json['format'],
      level: json['level'],
      textSize: json['textSize'],
      items: json['items'] != null ? List<String>.from(json['items']) : null,
    );
  }
}