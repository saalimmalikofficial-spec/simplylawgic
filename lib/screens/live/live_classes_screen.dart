import 'package:flutter/material.dart';

import '../../models/study_video.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../youtube_video_screen.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({super.key});

  @override
  State<LiveClassesScreen> createState() =>
      _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;

  List<StudyVideo> _videos = [];
  List<StudyVideo> _filteredVideos = [];

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final videos = await _apiService.getStudyVideos();

      videos.sort(
            (a, b) => a.sortOrder.compareTo(b.sortOrder),
      );

      if (!mounted) return;

      setState(() {
        _videos = videos;
        _filteredVideos = videos;
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

  void _filterVideos(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'All') {
        _filteredVideos = _videos;
      } else {
        _filteredVideos = _videos.where((video) {
          return video.badge.toLowerCase() ==
              filter.toLowerCase();
        }).toList();
      }
    });
  }

  void _openVideo(StudyVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubeVideoScreen(
          slug: video.slug,
        ),
      ),
    );
  }

  List<String> _getFilters() {
    final filters = <String>{'All'};

    for (final video in _videos) {
      if (video.badge.trim().isNotEmpty) {
        filters.add(video.badge);
      }
    }

    return filters.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bgColor =
    isDark ? const Color(0xFF0A0A0F) : AppColors.bg;

    final textColor =
    isDark ? Colors.white : AppColors.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark
            ? const Color(0xFF12121E)
            : AppColors.background,
        foregroundColor: textColor,
        title: Text(
          'Study Videos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVideos,
        child: _buildBody(isDark),
      ),
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

    if (_videos.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final filters = _getFilters();

    return Column(
      children: [
        const SizedBox(height: 12),

        _buildFilterChips(
          isDark,
          filters,
        ),

        const SizedBox(height: 8),

        Expanded(
          child: _filteredVideos.isEmpty
              ? _buildNoFilterResult(isDark)
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
            itemCount: _filteredVideos.length,
            itemBuilder: (context, index) {
              final video = _filteredVideos[index];

              return _buildVideoCard(
                video,
                isDark,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
      bool isDark,
      List<String> filters,
      ) {
    final textColor =
    isDark ? Colors.white : AppColors.textPrimary;

    final borderColor =
    isDark
        ? Colors.white.withOpacity(0.08)
        : AppColors.border;

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];

          final selected =
              _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : textColor,
                ),
              ),
              selected: selected,
              onSelected: (_) {
                _filterVideos(filter);
              },
              selectedColor: AppColors.primary,
              backgroundColor: isDark
                  ? const Color(0xFF1A1A2E)
                  : AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : borderColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(
      StudyVideo video,
      bool isDark,
      ) {
    final cardColor = isDark
        ? const Color(0xFF1A1A2E)
        : AppColors.background;

    final textColor =
    isDark ? Colors.white : AppColors.textDark;

    final secondaryColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.02)
                  : AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildThumbnail(
              video,
              isDark,
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (video.badge.isNotEmpty)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
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
                              fontSize: 9,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              AppColors.primary,
                            ),
                          ),
                        ),

                      const Spacer(),

                      if (video.duration.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons
                                  .access_time_rounded,
                              size: 13,
                              color:
                              secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              video.duration,
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                secondaryColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    video.title,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    video.excerpt,
                    maxLines: 3,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: secondaryColor,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _openVideo(video),
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              AppColors.primary,
                              foregroundColor:
                              Colors.white,
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons
                                  .play_arrow_rounded,
                              size: 19,
                            ),
                            label: const Text(
                              'Watch Video',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(
      StudyVideo video,
      bool isDark,
      ) {
    return ClipRRect(
      borderRadius:
      const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              video.thumbnailUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  color: isDark
                      ? const Color(0xFF12121E)
                      : Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons
                          .video_library_outlined,
                      size: 48,
                    ),
                  ),
                );
              },
              loadingBuilder:
                  (context, child, progress) {
                if (progress == null) {
                  return child;
                }

                return Container(
                  color: isDark
                      ? const Color(0xFF12121E)
                      : Colors.grey.shade200,
                  child: const Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black
                      .withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
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
              Icons
                  .cloud_off_rounded,
              size: 64,
              color: isDark
                  ? Colors.white38
                  : Colors.grey,
            ),

            const SizedBox(height: 16),

            Text(
              'Unable to load videos',
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
              onPressed: _loadVideos,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: isDark
                ? Colors.white38
                : Colors.grey,
          ),

          const SizedBox(height: 14),

          Text(
            'No study videos available',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : AppColors.textDark,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Please check back later.',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white70
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilterResult(bool isDark) {
    return Center(
      child: Text(
        'No videos found',
        style: TextStyle(
          color: isDark
              ? Colors.white70
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}