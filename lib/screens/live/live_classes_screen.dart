// lib/screens/live/live_classes_screen.dart

import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../youtube_video_screen.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({super.key});

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  final List<LiveClass> _liveClasses = [
    LiveClass(
      id: '1',
      title: 'BNS 2023 - Chapter 1: Introduction',
      instructor: 'Dr. Aditya Raj',
      time: 'Today, 6:00 PM',
      duration: '1.5 hrs',
      category: 'Criminal Law',
      isLive: true,
      viewers: 245,
      thumbnail: 'https://via.placeholder.com/400x200',
      description: 'Complete introduction to Bharatiya Nyaya Sanhita 2023',
      youtubeUrl: 'https://www.youtube.com/watch?v=7RxkJL29K0I',
    ),
    LiveClass(
      id: '2',
      title: 'Constitutional Law - Fundamental Rights',
      instructor: 'Prof. Meera Sharma',
      time: 'Today, 7:30 PM',
      duration: '2 hrs',
      category: 'Constitutional Law',
      isLive: false,
      viewers: 189,
      thumbnail: 'https://via.placeholder.com/400x200',
      description: 'Detailed discussion on Fundamental Rights',
      youtubeUrl: 'https://www.youtube.com/watch?v=7RxkJL29K0I',
    ),
    LiveClass(
      id: '3',
      title: 'Criminal Procedure Code - Chapter 3',
      instructor: 'Adv. Rohit Singh',
      time: 'Tomorrow, 5:00 PM',
      duration: '1.5 hrs',
      category: 'Criminal Law',
      isLive: false,
      viewers: 0,
      thumbnail: 'https://via.placeholder.com/400x200',
      description: 'Understanding CrPC provisions',
      youtubeUrl: 'https://www.youtube.com/watch?v=7RxkJL29K0I',
    ),
    LiveClass(
      id: '4',
      title: 'Evidence Law - Indian Evidence Act',
      instructor: 'Dr. Priya Patel',
      time: 'Tomorrow, 8:00 PM',
      duration: '2 hrs',
      category: 'Evidence Law',
      isLive: false,
      viewers: 0,
      thumbnail: 'https://via.placeholder.com/400x200',
      description: 'Complete coverage of Indian Evidence Act',
      youtubeUrl: 'https://www.youtube.com/watch?v=7RxkJL29K0I',
    ),
    LiveClass(
      id: '5',
      title: 'Legal Reasoning - Mock Session',
      instructor: 'Adv. Amit Kumar',
      time: 'Day after tomorrow, 6:30 PM',
      duration: '1.5 hrs',
      category: 'Legal Reasoning',
      isLive: false,
      viewers: 0,
      thumbnail: 'https://via.placeholder.com/400x200',
      description: 'Practice legal reasoning questions',
      youtubeUrl: 'https://www.youtube.com/watch?v=7RxkJL29K0I',
    ),
  ];

  List<LiveClass> _upcomingClasses = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _upcomingClasses = _liveClasses;
  }

  void _filterClasses(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'All') {
        _upcomingClasses = _liveClasses;
      } else if (filter == 'Live') {
        _upcomingClasses =
            _liveClasses.where((c) => c.isLive).toList();
      } else {
        _upcomingClasses =
            _liveClasses.where((c) => c.category == filter).toList();
      }
    });
  }

  void _openYoutubeVideo(LiveClass liveClass) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubeVideoScreen(
          youtubeUrl: liveClass.youtubeUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
    isDark ? const Color(0xFF0A0A0F) : AppColors.bg;

    final cardColor =
    isDark ? const Color(0xFF1A1A2E) : AppColors.background;

    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;

    final textColor =
    isDark ? Colors.white : AppColors.textDark;

    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    final primaryTextColor =
    isDark ? Colors.white70 : AppColors.textPrimary;

    final appBarBg =
    isDark ? const Color(0xFF12121E) : AppColors.background;

    final shadowColor =
    isDark ? Colors.white.withOpacity(0.03) : AppColors.cardShadow;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Text(
          'Live Classes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: textColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLiveNowBanner(isDark),
          _buildFilterChips(
            isDark,
            textColor,
            borderColor,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _upcomingClasses.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: _upcomingClasses.length,
              itemBuilder: (context, index) {
                final liveClass = _upcomingClasses[index];

                return _buildLiveClassCard(
                  liveClass,
                  isDark,
                  cardColor,
                  borderColor,
                  textColor,
                  secondaryTextColor,
                  primaryTextColor,
                  shadowColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveNowBanner(bool isDark) {
    final liveClasses =
    _liveClasses.where((c) => c.isLive).toList();

    if (liveClasses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.danger,
            Color(0xFFFF6B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.live_tv_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  liveClasses[0].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${liveClasses[0].viewers} watching right now',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.danger,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            onPressed: () {
              _openYoutubeVideo(liveClasses[0]);
            },
            child: const Text(
              'Join Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
      bool isDark,
      Color textColor,
      Color borderColor,
      ) {
    final filters = [
      'All',
      'Live',
      'Criminal Law',
      'Constitutional Law',
      'Evidence Law',
      'Legal Reasoning',
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];

          final isSelected =
              _selectedFilter == filter;

          final selectedChipColor =
          filter == 'Live'
              ? AppColors.danger
              : AppColors.primary;

          final chipBg = isSelected
              ? selectedChipColor
              : (isDark
              ? const Color(0xFF1A1A2E)
              : AppColors.background);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                      ? Colors.white70
                      : AppColors.textPrimary),
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _filterClasses(filter);
                }
              },
              selectedColor: selectedChipColor,
              backgroundColor: chipBg,
              elevation: isSelected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? selectedChipColor
                      : borderColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveClassCard(
      LiveClass liveClass,
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      Color primaryTextColor,
      Color shadowColor,
      ) {
    final actionButtonColor =
    liveClass.isLive
        ? AppColors.danger
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: isDark
                      ? const Color(0xFF12121E)
                      : AppColors.bg,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 52,
                      color: actionButtonColor.withOpacity(0.85),
                    ),
                  ),
                ),
              ),
              if (liveClass.isLive)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 6,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.8)
                        : AppColors.textDark.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        liveClass.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (liveClass.viewers > 0)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.8)
                          : AppColors.textDark.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${liveClass.viewers}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        liveClass.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white70
                              : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: isDark
                              ? Colors.white38
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          liveClass.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white38
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  liveClass.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 15,
                      color: isDark
                          ? Colors.white38
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      liveClass.instructor,
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  liveClass.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionButtonColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _openYoutubeVideo(liveClass);
                          },
                          child: Text(
                            liveClass.isLive
                                ? 'Join Live'
                                : 'Watch Video',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0A0A0F)
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.bookmark_outline_rounded,
                          color: isDark
                              ? Colors.white38
                              : AppColors.accentGrey,
                          size: 20,
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
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor =
    isDark ? Colors.white : AppColors.textDark;

    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    final iconColor =
    isDark
        ? Colors.white.withOpacity(0.3)
        : AppColors.textMuted;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No classes available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back later for upcoming live classes',
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveClass {
  final String id;
  final String title;
  final String instructor;
  final String time;
  final String duration;
  final String category;
  final bool isLive;
  final int viewers;
  final String thumbnail;
  final String description;

  // YouTube video URL
  final String youtubeUrl;

  LiveClass({
    required this.id,
    required this.title,
    required this.instructor,
    required this.time,
    required this.duration,
    required this.category,
    required this.isLive,
    required this.viewers,
    required this.thumbnail,
    required this.description,
    required this.youtubeUrl,
  });
}