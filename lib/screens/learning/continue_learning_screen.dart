// lib/screens/learning/continue_learning_screen.dart
import 'package:flutter/material.dart';

class ContinueLearningScreen extends StatefulWidget {
  const ContinueLearningScreen({super.key});

  @override
  State<ContinueLearningScreen> createState() => _ContinueLearningScreenState();
}

class _ContinueLearningScreenState extends State<ContinueLearningScreen> {
  final List<LearningItem> _learningItems = [
    LearningItem(
      id: '1',
      title: 'Integration & Calculus',
      subtitle: 'Chapter 4 • Lecture 2 of 8',
      progress: 0.6,
      icon: Icons.functions,
      color: const Color(0xFF6C5CE7),
      category: 'Mathematics',
      duration: '45 mins remaining',
    ),
    LearningItem(
      id: '2',
      title: 'Constitutional Law',
      subtitle: 'Chapter 3 • Lecture 5 of 12',
      progress: 0.35,
      icon: Icons.gavel,
      color: const Color(0xFF00B894),
      category: 'Law',
      duration: '1.2 hrs remaining',
    ),
    LearningItem(
      id: '3',
      title: 'Criminal Procedure Code',
      subtitle: 'Chapter 2 • Lecture 3 of 10',
      progress: 0.75,
      icon: Icons.description,
      color: const Color(0xFFFDCB6E),
      category: 'Law',
      duration: '20 mins remaining',
    ),
    LearningItem(
      id: '4',
      title: 'Legal Reasoning',
      subtitle: 'Chapter 1 • Lecture 4 of 6',
      progress: 0.9,
      icon: Icons.psychology,
      color: const Color(0xFFE17055),
      category: 'Reasoning',
      duration: '10 mins remaining',
    ),
    LearningItem(
      id: '5',
      title: 'English Grammar',
      subtitle: 'Chapter 5 • Lecture 3 of 8',
      progress: 0.45,
      icon: Icons.translate,
      color: const Color(0xFF0984E3),
      category: 'Language',
      duration: '55 mins remaining',
    ),
    LearningItem(
      id: '6',
      title: 'Current Affairs',
      subtitle: 'Chapter 6 • Lecture 2 of 15',
      progress: 0.2,
      icon: Icons.newspaper,
      color: const Color(0xFFE17055),
      category: 'GK',
      duration: '2.5 hrs remaining',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Continue Learning',
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
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.play_circle_outline,
                  label: 'In Progress',
                  value: '6',
                  color: const Color(0xFF6C5CE7),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade200,
                ),
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: '12',
                  color: const Color(0xFF00B894),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade200,
                ),
                _buildStatItem(
                  icon: Icons.access_time_outlined,
                  label: 'Total Hours',
                  value: '28.5',
                  color: const Color(0xFFFDCB6E),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  _buildFilterChip('Mathematics', false),
                  _buildFilterChip('Law', false),
                  _buildFilterChip('Reasoning', false),
                  _buildFilterChip('Language', false),
                  _buildFilterChip('GK', false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Learning List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _learningItems.length,
              itemBuilder: (context, index) {
                final item = _learningItems[index];
                return _buildLearningCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          // Handle filter selection
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
  }

  Widget _buildLearningCard(LearningItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: item.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.duration,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Progress
              Column(
                children: [
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: Colors.grey.shade200,
                        color: item.color,
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to lecture
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6C5CE7),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // Bookmark
                },
                icon: Icon(
                  Icons.bookmark_outline,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  // More options
                },
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Learning Item Model
class LearningItem {
  final String id;
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color color;
  final String category;
  final String duration;

  LearningItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.color,
    required this.category,
    required this.duration,
  });
}