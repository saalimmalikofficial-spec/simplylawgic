// lib/screens/dashboard/tabs/home_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/models/subject_notes.dart';
import 'package:simplylawgic/utils/app_colors.dart';

import '../../notes/note_detail_screen.dart';
import '../../notes/all_subject_notes_screen.dart';
import '../../user_progress_screen.dart';

class HomeTab extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeTab({super.key, this.scaffoldKey});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // ---------- State ----------
  List<SubjectNotes> _subjectNotes = [];
  List<SubjectNotes> _examNotes = [];
  bool _isLoading = true;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  static const _bannerImages = [
    'assets/images/b1.png',
    'assets/images/b2.png',
    'assets/images/b3.png',
  ];

  static const _bannerInterval = Duration(seconds: 4);

  // ---------- Lifecycle ----------
  @override
  void initState() {
    super.initState();
    _loadAllNotes();
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // ---------- Data ----------
  Future<void> _loadAllNotes() async {
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
        _examNotes = notes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- Banner ----------
  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(_bannerInterval, (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % _bannerImages.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onBannerChanged(int index) {
    setState(() => _currentBannerIndex = index);
    _startBannerAutoSlide();
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.bg;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDark),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadAllNotes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerSlider(isDark),
                const SizedBox(height: 16),

                _buildNotesSection(
                  title: 'Subject-Wise Notes',
                  notes: _subjectNotes,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),

                const SizedBox(height: 20),

                _buildNotesSection(
                  title: 'Exam-Wise Notes',
                  notes: _examNotes,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- AppBar ----------
  // ✅ Menu icon (left)  +  Logo (right)
  PreferredSizeWidget _buildAppBar(bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.bg;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 60,

      // 🔹 LEFT — Menu icon
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: _RoundedIconBox(
            icon: Icons.menu_rounded,
            isDark: isDark,
            semanticLabel: 'Open menu',
            onTap: () => widget.scaffoldKey?.currentState?.openDrawer(),
          ),
        ),
      ),

      // 🔹 Title khaali — kuch nahi dikhana
      title: const SizedBox.shrink(),

      // 🔹 RIGHT — App logo
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(child: _buildLogo()),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.gavel_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ---------- Sections ----------
  Widget _buildNotesSection({
    required String title,
    required List<SubjectNotes> notes,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle(title: title, textColor: textColor),
            const Spacer(),
            _ViewAllButton(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllSubjectNotesScreen(title: title),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildNotesContent(
          notes: notes,
          isDark: isDark,
          cardColor: cardColor,
          borderColor: borderColor,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
      ],
    );
  }

  Widget _buildNotesContent({
    required List<SubjectNotes> notes,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _StateCard(
        cardColor: cardColor,
        borderColor: borderColor,
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.danger,
        message: _errorMessage!,
        actionLabel: 'Retry',
        onAction: _loadAllNotes,
        secondaryTextColor: secondaryTextColor,
      );
    }

    if (notes.isEmpty) {
      return _StateCard(
        cardColor: cardColor,
        borderColor: borderColor,
        icon: Icons.menu_book_rounded,
        iconColor: AppColors.primary,
        message: 'No notes available',
        secondaryTextColor: secondaryTextColor,
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 4),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final note = notes[index];
          return SubjectNoteCard(
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
      ),
    );
  }

  // ---------- Banner ----------
  Widget _buildBannerSlider(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : AppColors.cardShadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _bannerController,
                itemCount: _bannerImages.length,
                onPageChanged: _onBannerChanged,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _bannerImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 40,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.22),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _bannerImages.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: _currentBannerIndex == i ? 18 : 6,
                      decoration: BoxDecoration(
                        color: _currentBannerIndex == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Utils ----------
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// =============================================================
// Reusable Widgets
// =============================================================

class _RoundedIconBox extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showBadge;
  final String? semanticLabel;

  const _RoundedIconBox({
    required this.icon,
    required this.isDark,
    this.onTap,
    this.iconColor,
    this.showBadge = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
        ),
      ),
      child: Icon(
        icon,
        color: iconColor ?? (isDark ? Colors.white : AppColors.textDark),
        size: 20,
      ),
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            box,
            if (showBadge)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0A0A0F) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionTitle({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 4,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onTap,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View All',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          SizedBox(width: 2),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 11,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color secondaryTextColor;

  const _StateCard({
    required this.cardColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.secondaryTextColor,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryTextColor, fontSize: 13),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
// Subject Note Card
// =============================================================

class SubjectNoteCard extends StatelessWidget {
  final SubjectNotes note;
  final bool isDark;
  final VoidCallback onTap;

  static const String _defaultImageUrl =
      'https://images.unsplash.com/photo-1505664194779-8beaceb93744?auto=format&fit=crop&w=800&q=80';

  const SubjectNoteCard({
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

    return SizedBox(
      width: 250,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: catColor.withValues(alpha: 0.08),
          highlightColor: catColor.withValues(alpha: 0.04),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
                  child: SizedBox(
                    height: 92,
                    width: double.infinity,
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
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    catColor,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 34,
                              color: catColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CategoryTag(
                              label: note.subjectCategory,
                              color: catColor,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              note.displayTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                                fontSize: 11.5,
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
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}