// lib/screens/notes/all_subject_notes_screen.dart
import 'package:flutter/material.dart';

import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/models/subject_notes.dart';
import 'package:simplylawgic/screens/notes/note_detail_screen.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class AllSubjectNotesScreen extends StatefulWidget {
  /// Title shown in the AppBar (e.g. "Subject-Wise Notes" / "Exam-Wise Notes")
  final String title;

  const AllSubjectNotesScreen({
    super.key,
    required this.title,
  });

  @override
  State<AllSubjectNotesScreen> createState() => _AllSubjectNotesScreenState();
}

class _AllSubjectNotesScreenState extends State<AllSubjectNotesScreen> {
  final ApiService _apiService = ApiService();

  List<SubjectNotes> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notes = await _apiService.getSubjectNotes();
      if (!mounted) return;
      setState(() => _notes = notes);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.bg;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadNotes,
        child: _buildBody(isDark, secondaryTextColor),
      ),
    );
  }

  Widget _buildBody(bool isDark, Color secondaryTextColor) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, secondaryTextColor);
    }

    if (_notes.isEmpty) {
      return _buildEmptyState(isDark, secondaryTextColor);
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return SubjectNoteGridCard(
          note: note,
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailScreen(slug: note.slug),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(bool isDark, Color secondaryTextColor) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border;

    return ListView(
      // so pull-to-refresh works
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryTextColor, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _loadNotes,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, Color secondaryTextColor) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No notes available',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================
// Grid Card — smaller, vertical layout (fits 2 columns)
// =============================================================

class SubjectNoteGridCard extends StatelessWidget {
  final SubjectNotes note;
  final bool isDark;
  final VoidCallback onTap;

  /// 🔥 Default fallback image
  static const String _defaultImageUrl =
      'https://images.unsplash.com/photo-1505664194779-8beaceb93744?auto=format&fit=crop&w=800&q=80';

  const SubjectNoteGridCard({
    super.key,
    required this.note,
    required this.isDark,
    required this.onTap,
  });

  Color _categoryColor(String category) {
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
    final catColor = _categoryColor(note.subjectCategory);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border;
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : AppColors.cardShadow;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    final imageUrl = note.heroBookImageUrl.isNotEmpty
        ? note.heroBookImageUrl
        : _defaultImageUrl;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: catColor.withValues(alpha: 0.08),
        highlightColor: catColor.withValues(alpha: 0.04),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              catColor.withValues(alpha: 0.16),
                              catColor.withValues(alpha: 0.06),
                            ],
                          ),
                        ),
                      ),
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(catColor),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 30,
                            color: catColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              note.subjectCategory.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            note.displayTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: textColor,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            note.tagline.isNotEmpty
                                ? note.tagline
                                : note.subjectName,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: secondaryTextColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Read',
                            style: TextStyle(
                              fontSize: 11,
                              color: catColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
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