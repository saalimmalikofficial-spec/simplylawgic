class StudyVideo {
  final String id;
  final String slug;
  final String title;
  final String excerpt;
  final String thumbnailUrl;
  final String badge;
  final String duration;
  final int sortOrder;
  final String youtubeUrl;
  final String youtubeVideoId;
  final String status;
  final DateTime? publishedAt;

  StudyVideo({
    required this.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.thumbnailUrl,
    required this.badge,
    required this.duration,
    required this.sortOrder,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    required this.status,
    this.publishedAt,
  });

  factory StudyVideo.fromJson(Map<String, dynamic> json) {
    return StudyVideo(
      id: json['_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      youtubeUrl: json['youtubeUrl']?.toString() ?? '',
      youtubeVideoId: json['youtubeVideoId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
    );
  }
}


class StudyVideoDetail {
  final String id;
  final String slug;
  final String title;
  final String excerpt;
  final String thumbnailUrl;
  final String badge;
  final String duration;
  final String youtubeUrl;
  final String youtubeVideoId;

  final String playerImageUrl;
  final String viewsLabel;
  final String notesFileUrl;
  final String notesFileName;
  final String language;

  final String aboutVideo;

  final String instructorName;
  final String instructorPhotoUrl;
  final String instructorBio;

  final StudyVideoStats stats;
  final SidebarCta sidebarCta;
  final HelpSection help;

  StudyVideoDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.thumbnailUrl,
    required this.badge,
    required this.duration,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    required this.playerImageUrl,
    required this.viewsLabel,
    required this.notesFileUrl,
    required this.notesFileName,
    required this.language,
    required this.aboutVideo,
    required this.instructorName,
    required this.instructorPhotoUrl,
    required this.instructorBio,
    required this.stats,
    required this.sidebarCta,
    required this.help,
  });

  factory StudyVideoDetail.fromJson(Map<String, dynamic> json) {
    return StudyVideoDetail(
      id: json['_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      excerpt: json['excerpt']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      youtubeUrl: json['youtubeUrl']?.toString() ?? '',
      youtubeVideoId: json['youtubeVideoId']?.toString() ?? '',
      playerImageUrl: json['playerImageUrl']?.toString() ?? '',
      viewsLabel: json['viewsLabel']?.toString() ?? '',
      notesFileUrl: json['notesFileUrl']?.toString() ?? '',
      notesFileName: json['notesFileName']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      aboutVideo: json['aboutVideo']?.toString() ?? '',
      instructorName: json['instructorName']?.toString() ?? '',
      instructorPhotoUrl: json['instructorPhotoUrl']?.toString() ?? '',
      instructorBio: json['instructorBio']?.toString() ?? '',
      stats: StudyVideoStats.fromJson(
        json['stats'] is Map
            ? Map<String, dynamic>.from(json['stats'])
            : {},
      ),
      sidebarCta: SidebarCta.fromJson(
        json['sidebarCta'] is Map
            ? Map<String, dynamic>.from(json['sidebarCta'])
            : {},
      ),
      help: HelpSection.fromJson(
        json['help'] is Map
            ? Map<String, dynamic>.from(json['help'])
            : {},
      ),
    );
  }
}


class StudyVideoStats {
  final String totalViews;
  final String studentsEnrolled;
  final String averageRating;
  final String downloads;

  StudyVideoStats({
    required this.totalViews,
    required this.studentsEnrolled,
    required this.averageRating,
    required this.downloads,
  });

  factory StudyVideoStats.fromJson(Map<String, dynamic> json) {
    return StudyVideoStats(
      totalViews: json['totalViews']?.toString() ?? '0',
      studentsEnrolled: json['studentsEnrolled']?.toString() ?? '0',
      averageRating: json['averageRating']?.toString() ?? '0',
      downloads: json['downloads']?.toString() ?? '0',
    );
  }
}


class SidebarCta {
  final String title;
  final String body;
  final String primaryLabel;
  final String primaryUrl;
  final String secondaryLabel;
  final String secondaryUrl;
  final String imageUrl;

  SidebarCta({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.primaryUrl,
    required this.secondaryLabel,
    required this.secondaryUrl,
    required this.imageUrl,
  });

  factory SidebarCta.fromJson(Map<String, dynamic> json) {
    return SidebarCta(
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      primaryLabel: json['primaryLabel']?.toString() ?? '',
      primaryUrl: json['primaryUrl']?.toString() ?? '',
      secondaryLabel: json['secondaryLabel']?.toString() ?? '',
      secondaryUrl: json['secondaryUrl']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}


class HelpSection {
  final String title;
  final String body;
  final String whatsappUrl;
  final String whatsappLabel;

  HelpSection({
    required this.title,
    required this.body,
    required this.whatsappUrl,
    required this.whatsappLabel,
  });

  factory HelpSection.fromJson(Map<String, dynamic> json) {
    return HelpSection(
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      whatsappUrl: json['whatsappUrl']?.toString() ?? '',
      whatsappLabel: json['whatsappLabel']?.toString() ?? '',
    );
  }
}