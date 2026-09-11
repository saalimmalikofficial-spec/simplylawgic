// lib/screens/dashboard/tabs/home_tab.dart
import 'package:flutter/material.dart';

import 'package:simplylawgic/widgets/quick_action_item.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/models/subject_notes.dart';
import 'package:simplylawgic/screens/notes/note_detail_screen.dart';
import 'package:simplylawgic/screens/learning/continue_learning_screen.dart';
import 'package:simplylawgic/screens/live/live_classes_screen.dart';
import 'package:simplylawgic/utils/app_colors.dart';

import '../../user_progress_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<SubjectNotes> _subjectNotes = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSubjectNotes();
  }

  Future<void> _loadSubjectNotes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notes = await _apiService.getSubjectNotes();
      if (!mounted) return;
      setState(() {
        _subjectNotes = notes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Directly detect theme from context - this works every time
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.bg;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : AppColors.background;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.border;
    final shadowColor = isDark ? Colors.white.withOpacity(0.03) : AppColors.cardShadow;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadSubjectNotes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLiveBanner(context, isDark),
                const SizedBox(height: 20),
                _buildQuickActionsGrid(context, isDark, cardColor, borderColor, shadowColor),
                const SizedBox(height: 24),
                _buildContinueLearningSection(context, isDark, cardColor, borderColor, shadowColor, textColor, secondaryTextColor),
                const SizedBox(height: 24),
                _buildSubjectNotesHeader(context, isDark, textColor),
                const SizedBox(height: 12),
                _buildSubjectNotesContent(isDark, cardColor, borderColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBanner(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withOpacity(0.05) : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/b1.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.textDark.withOpacity(0.8),
                    AppColors.textDark.withOpacity(0.3),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Mock Test Live! 🎯",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "All India Rank Prediction Test is now active.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Attempting test...'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
                        ),
                      );
                    },
                    child: const Text(
                      "Attempt Now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool isDark, Color cardColor, Color borderColor, Color shadowColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionItem(
            icon: Icons.play_circle_fill_rounded,
            title: "Live Classes",
            color: AppColors.danger,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveClassesScreen(),
                ),
              );
            },
          ),
          QuickActionItem(
            icon: Icons.menu_book_rounded,
            title: "PDF Notes",
            color: AppColors.warning,
            onTap: () => _showSnackBar(context, 'PDF Notes feature coming soon!', isDark),
          ),
          QuickActionItem(
            icon: Icons.assignment_turned_in_rounded,
            title: "Test Series",
            color: AppColors.primary,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const TestsTabHometab(), // ✅ Ab error nahi aayega
              //   ),
              // );
            },
          ),
          QuickActionItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            color: AppColors.success,
            onTap: () => // Or use navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProgressScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningSection(BuildContext context, bool isDark, Color cardColor, Color borderColor, Color shadowColor, Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Continue Learning",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContinueLearningScreen(),
                  ),
                );
              },
              child: const Text(
                "View All",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContinueLearningScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.functions_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Integration & Calculus",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Chapter 4 • Lecture 2 of 8",
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          minHeight: 5,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white.withOpacity(0.3) : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectNotesHeader(BuildContext context, bool isDark, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Subject-Wise Notes",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        TextButton(
          onPressed: () => _showSnackBar(context, 'View all notes coming soon!', isDark),
          child: const Text(
            "View All",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectNotesContent(bool isDark, Color cardColor, Color borderColor) {
    if (_isLoading) {
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadSubjectNotes,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_subjectNotes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.menu_book_rounded, size: 48, color: isDark ? Colors.white.withOpacity(0.3) : AppColors.textMuted),
              const SizedBox(height: 8),
              Text(
                'No notes available',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _subjectNotes.length,
        itemBuilder: (context, index) {
          final note = _subjectNotes[index];
          return SubjectNoteCard(
            subjectName: note.subjectName,
            displayTitle: note.displayTitle,
            tagline: note.tagline,
            heroBookImageUrl: note.heroBookImageUrl,
            subjectCategory: note.subjectCategory,
            slug: note.slug,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(slug: note.slug),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      ),
    );
  }
}

class SubjectNoteCard extends StatelessWidget {
  final String subjectName;
  final String displayTitle;
  final String tagline;
  final String heroBookImageUrl;
  final String subjectCategory;
  final String slug;
  final bool isDark;
  final VoidCallback onTap;

  const SubjectNoteCard({
    super.key,
    required this.subjectName,
    required this.displayTitle,
    required this.tagline,
    required this.heroBookImageUrl,
    required this.subjectCategory,
    required this.slug,
    required this.isDark,
    required this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'major laws':
        return AppColors.primary;
      case 'minor laws':
        return AppColors.secondary;
      case 'procedural laws':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(subjectCategory);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : AppColors.background;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.border;
    final shadowColor = isDark ? Colors.white.withOpacity(0.03) : AppColors.cardShadow;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 90,
                  width: double.infinity,
                  color: catColor.withOpacity(0.12),
                  child: heroBookImageUrl.isNotEmpty
                      ? Image.network(
                    heroBookImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.menu_book_rounded, size: 36, color: catColor),
                    ),
                  )
                      : Center(
                    child: Icon(Icons.menu_book_rounded, size: 36, color: catColor),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subjectCategory.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tagline.isNotEmpty ? tagline : subjectName,
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Read Notes',
                            style: TextStyle(
                              fontSize: 12,
                              color: catColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: catColor,
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
      ),
    );
  }
}