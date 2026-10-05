import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'models/study_video.dart';
import 'services/api_service.dart';
import 'utils/app_colors.dart';

class YoutubeVideoScreen extends StatefulWidget {
  final String slug;

  const YoutubeVideoScreen({
    super.key,
    required this.slug,
  });

  @override
  State<YoutubeVideoScreen> createState() =>
      _YoutubeVideoScreenState();
}

class _YoutubeVideoScreenState
    extends State<YoutubeVideoScreen> {
  final ApiService _apiService = ApiService();

  YoutubePlayerController? _controller;

  StudyVideoDetail? _video;
  List<StudyVideo> _relatedVideos = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getStudyVideoBySlug(widget.slug),
        _apiService.getStudyVideos(),
      ]);

      final detail =
      results[0] as StudyVideoDetail;

      final allVideos =
      results[1] as List<StudyVideo>;

      final related = allVideos
          .where(
            (video) =>
        video.slug != detail.slug,
      )
          .toList();

      related.sort(
            (a, b) => a.sortOrder.compareTo(b.sortOrder),
      );

      final videoId =
      detail.youtubeVideoId.isNotEmpty
          ? detail.youtubeVideoId
          : extractYoutubeVideoId(
        detail.youtubeUrl,
      );

      if (videoId == null ||
          videoId.isEmpty) {
        throw Exception(
          'Invalid YouTube video',
        );
      }

      final controller =
      YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: true,
          strictRelatedVideos: true,
        ),
      );

      if (!mounted) {
        controller.close();
        return;
      }

      _controller?.close();

      setState(() {
        _video = detail;
        _relatedVideos = related;
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _openRelatedVideo(StudyVideo video) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubeVideoScreen(
          slug: video.slug,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF0A0A0F)
        : AppColors.bg;

    final textColor = isDark
        ? Colors.white
        : AppColors.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF12121E)
            : AppColors.background,
        foregroundColor: textColor,
        title: const Text(
          'Study Video',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    if (_video == null ||
        _controller == null) {
      return const Center(
        child: Text('Video not found'),
      );
    }

    final video = _video!;

    return RefreshIndicator(
      onRefresh: _loadVideo,
      child: ListView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          _buildPlayer(),

          _buildVideoInfo(
            video,
            isDark,
          ),

          _buildStats(
            video,
            isDark,
          ),

          _buildAbout(
            video,
            isDark,
          ),

          _buildInstructor(
            video,
            isDark,
          ),

          if (_relatedVideos.isNotEmpty)
            _buildMoreVideos(
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayer(
        controller: _controller!,
        aspectRatio: 16 / 9,
      ),
    );
  }

  Widget _buildVideoInfo(
      StudyVideoDetail video,
      bool isDark,
      ) {
    final secondaryColor = isDark
        ? Colors.white70
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        8,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          if (video.badge.isNotEmpty)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(6),
              ),
              child: Text(
                video.badge.toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),

          const SizedBox(height: 10),

          Text(
            video.title,
            style: TextStyle(
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : AppColors.textDark,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: secondaryColor,
              ),
              const SizedBox(width: 5),
              Text(
                video.viewsLabel.isEmpty
                    ? '0 views'
                    : '${video.viewsLabel} views',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),

              const SizedBox(width: 14),

              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: secondaryColor,
              ),
              const SizedBox(width: 5),
              Text(
                video.duration,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),

              if (video.language.isNotEmpty) ...[
                const SizedBox(width: 14),
                Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: secondaryColor,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    video.language,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
      StudyVideoDetail video,
      bool isDark,
      ) {
    final stats = video.stats;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E)
            : AppColors.background,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.visibility_outlined,
              stats.totalViews,
              'Views',
              isDark,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.people_outline,
              stats.studentsEnrolled,
              'Students',
              isDark,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.star_outline_rounded,
              stats.averageRating,
              'Rating',
              isDark,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.download_outlined,
              stats.downloads,
              'Downloads',
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon,
      String value,
      String label,
      bool isDark,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.primary,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white
                : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? Colors.white54
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAbout(
      StudyVideoDetail video,
      bool isDark,
      ) {
    if (video.aboutVideo.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _section(
      title: 'About This Video',
      isDark: isDark,
      child: Text(
        _cleanAboutVideo(video.aboutVideo),
        style: TextStyle(
          fontSize: 13,
          height: 1.55,
          color: isDark
              ? Colors.white70
              : AppColors.textSecondary,
        ),
      ),
    );
  }

  String _cleanAboutVideo(String text) {
    final websiteIndex =
    text.indexOf('🌐 Website:');

    if (websiteIndex != -1) {
      return text
          .substring(0, websiteIndex)
          .trim();
    }

    return text.trim();
  }

  Widget _buildInstructor(
      StudyVideoDetail video,
      bool isDark,
      ) {
    if (video.instructorName.isEmpty) {
      return const SizedBox.shrink();
    }

    return _section(
      title: 'Instructor',
      isDark: isDark,
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              width: 58,
              height: 58,
              child: video.instructorPhotoUrl
                  .isNotEmpty
                  ? Image.network(
                video.instructorPhotoUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) {
                  return _instructorPlaceholder();
                },
              )
                  : _instructorPlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  video.instructorName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),

                if (video.instructorBio
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    video.instructorBio,
                    maxLines: 4,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructorPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  Widget _buildMoreVideos(bool isDark) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            10,
          ),
          child: Text(
            'More Videos',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : AppColors.textDark,
            ),
          ),
        ),

        ..._relatedVideos.map(
              (video) => _buildRelatedCard(
            video,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedCard(
      StudyVideo video,
      bool isDark,
      ) {
    return InkWell(
      onTap: () => _openRelatedVideo(video),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          16,
          6,
          16,
          6,
        ),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A2E)
              : AppColors.background,
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
              BorderRadius.circular(8),
              child: SizedBox(
                width: 125,
                height: 72,
                child: Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons
                            .video_library_outlined,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: isDark
                            ? Colors.white54
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        video.duration,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E)
            : AppColors.background,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : AppColors.textDark,
            ),
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: isDark
                  ? Colors.white38
                  : Colors.grey,
            ),

            const SizedBox(height: 15),

            Text(
              'Unable to load video',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: _loadVideo,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }
}


// ======================================================
// YOUTUBE URL → VIDEO ID
// ======================================================

String? extractYoutubeVideoId(String url) {
  final uri = Uri.tryParse(url);

  if (uri == null) return null;

  if (uri.host.contains('youtu.be')) {
    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
  }

  if (uri.host.contains('youtube.com')) {
    final videoId =
    uri.queryParameters['v'];

    if (videoId != null &&
        videoId.isNotEmpty) {
      return videoId;
    }

    if (uri.pathSegments.contains('embed')) {
      final index =
      uri.pathSegments.indexOf('embed');

      if (index + 1 <
          uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }
  }

  return null;
}