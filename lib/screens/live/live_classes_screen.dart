// lib/screens/live/live_classes_screen.dart
import 'package:flutter/material.dart';

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
        _upcomingClasses = _liveClasses.where((c) => c.isLive).toList();
      } else {
        _upcomingClasses = _liveClasses
            .where((c) => c.category == filter)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Live Classes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notification
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Now Banner
          _buildLiveNowBanner(),

          // Filter Chips
          _buildFilterChips(),

          // Upcoming Classes List
          Expanded(
            child: _upcomingClasses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _upcomingClasses.length,
              itemBuilder: (context, index) {
                final liveClass = _upcomingClasses[index];
                return _buildLiveClassCard(liveClass);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveNowBanner() {
    final liveClasses = _liveClasses.where((c) => c.isLive).toList();
    if (liveClasses.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF4757)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.live_tv,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔴 LIVE NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  liveClasses[0].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${liveClasses[0].viewers} watching',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF4757),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              // Join live class
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

  Widget _buildFilterChips() {
    final filters = ['All', 'Live', 'Criminal Law', 'Constitutional Law', 'Evidence Law', 'Legal Reasoning'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _filterClasses(filter);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF6C5CE7),
              side: BorderSide(
                color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveClassCard(LiveClass liveClass) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              // Live Badge
              if (liveClass.isLive)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 8,
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
              // Duration Badge
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        liveClass.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Viewers
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${liveClass.viewers}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        liveClass.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          liveClass.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  liveClass.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      liveClass.instructor,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        liveClass.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: liveClass.isLive
                              ? const Color(0xFFFF4757)
                              : const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          if (liveClass.isLive) {
                            // Join live
                          } else {
                            // Schedule reminder
                          }
                        },
                        child: Text(
                          liveClass.isLive ? 'Join Live' : 'Schedule Reminder',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        // Bookmark
                      },
                      icon: const Icon(
                        Icons.bookmark_outline,
                        color: Colors.grey,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No classes available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for upcoming live classes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// Live Class Model
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
  });
}