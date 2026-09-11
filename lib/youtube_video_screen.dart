import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoScreen extends StatefulWidget {
  final String youtubeUrl;

  const YoutubeVideoScreen({
    super.key,
    required this.youtubeUrl,
  });

  @override
  State<YoutubeVideoScreen> createState() => _YoutubeVideoScreenState();
}

class _YoutubeVideoScreenState extends State<YoutubeVideoScreen> {
  late YoutubePlayerController controller;

  final List<YoutubeVideoItem> relatedVideos = [
    YoutubeVideoItem(
      title: 'Daily Current Affairs - Video 1',
      subtitle: 'Current Affairs',
      youtubeUrl: 'https://www.youtube.com/watch?v=tIQFVeJCkbY',
    ),
    YoutubeVideoItem(
      title: 'Daily Current Affairs - Video 2',
      subtitle: 'Current Affairs',
      youtubeUrl: 'https://www.youtube.com/watch?v=Mt8_OACZZP0',
    ),
    YoutubeVideoItem(
      title: 'Daily Current Affairs - Video 3',
      subtitle: 'Current Affairs',
      youtubeUrl: 'https://www.youtube.com/watch?v=cxOcdWZypjM',
    ),
    YoutubeVideoItem(
      title: 'Daily Current Affairs - Video 3',
      subtitle: 'Current Affairs',
      youtubeUrl: 'https://www.youtube.com/watch?v=7b44zIiK2WE',
    ),


  ];

  @override
  void initState() {
    super.initState();

    final videoId = extractYoutubeVideoId(widget.youtubeUrl);

    if (videoId == null) {
      throw Exception('Invalid YouTube URL');
    }

    controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video'),
      ),
      body: ListView(
        children: [
          // =========================
          // CURRENT VIDEO
          // =========================
          YoutubePlayer(
            controller: controller,
            aspectRatio: 16 / 9,
          ),

          const SizedBox(height: 20),

          // =========================
          // MORE VIDEOS TITLE
          // =========================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'More Videos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // RELATED VIDEOS
          // =========================
          ...relatedVideos.map(
                (video) => _buildVideoCard(video),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVideoCard(YoutubeVideoItem video) {
    final videoId = extractYoutubeVideoId(video.youtubeUrl);

    return InkWell(
      onTap: () {
        if (videoId == null) return;

        // Current player mein new video load karo
        controller.loadVideoById(
          videoId: videoId,
        );

        // Screen ko top par le jao
        // optional
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // THUMBNAIL
            // =========================
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: 130,
                height: 80,
                child: videoId == null
                    ? Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.video_library,
                    size: 32,
                  ),
                )
                    : Image.network(
                  'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.video_library,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),

            // =========================
            // VIDEO DETAILS
            // =========================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      video.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Watch Video',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }
}

// ======================================================
// VIDEO MODEL
// ======================================================

class YoutubeVideoItem {
  final String title;
  final String subtitle;
  final String youtubeUrl;

  YoutubeVideoItem({
    required this.title,
    required this.subtitle,
    required this.youtubeUrl,
  });
}

// ======================================================
// EXTRACT YOUTUBE VIDEO ID
// ======================================================

String? extractYoutubeVideoId(String url) {
  final uri = Uri.tryParse(url);

  if (uri == null) return null;

  // https://youtu.be/VIDEO_ID
  if (uri.host.contains('youtu.be')) {
    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
  }

  // https://youtube.com/watch?v=VIDEO_ID
  if (uri.host.contains('youtube.com')) {
    final videoId = uri.queryParameters['v'];

    if (videoId != null && videoId.isNotEmpty) {
      return videoId;
    }

    // https://youtube.com/embed/VIDEO_ID
    if (uri.pathSegments.contains('embed')) {
      final index = uri.pathSegments.indexOf('embed');

      if (index + 1 < uri.pathSegments.length) {
        return uri.pathSegments[index + 1];
      }
    }
  }

  return null;
}