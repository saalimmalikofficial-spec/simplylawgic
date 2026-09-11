// lib/screens/notes/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/models/subject_notes.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class NoteDetailScreen extends StatefulWidget {
  final String slug;

  const NoteDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> with WidgetsBindingObserver {
  SubjectNotes? _note;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDark = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNoteDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      if (_isDark != isDark) {
        setState(() {
          _isDark = isDark;
        });
      }
    }
  }

  Future<void> _loadNoteDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final note = await _apiService.getSubjectNoteBySlug(widget.slug);
      setState(() {
        _note = note;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isDark != isDark) _isDark = isDark;

    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade800;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200;
    final appBarColor = isDark ? const Color(0xFF12121A) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.white : AppColors.primary,
          ),
        ),
      )
          : _errorMessage != null
          ? _buildErrorView(isDark)
          : _buildNoteContent(isDark, textColor, secondaryTextColor, cardColor, borderColor, appBarColor),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: isDark ? Colors.red.shade400 : Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNoteDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteContent(
      bool isDark,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      Color borderColor,
      Color appBarColor,
      ) {
    final note = _note!;
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          elevation: 0,
          backgroundColor: appBarColor,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image or Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    image: note.heroBannerUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(note.heroBannerUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                        : null,
                  ),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Content on Image
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          note.subjectCategory.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        note.displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      if (note.tagline.isNotEmpty)
                        Text(
                          note.tagline,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content Body
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Render all blocks
              ...note.blocks.map((block) => _renderBlock(block, isDark, textColor, secondaryTextColor, cardColor, borderColor)).toList(),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _renderBlock(
      Block block,
      bool isDark,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      Color borderColor,
      ) {
    switch (block.type) {
      case 'heading':
        return _buildHeading(block.payload, isDark, textColor);
      case 'subheading':
        return _buildSubheading(block.payload, isDark, textColor);
      case 'paragraph':
        return _buildParagraph(block.payload, isDark, secondaryTextColor);
      case 'bullet_list':
        return _buildBulletList(block.payload, isDark, textColor, secondaryTextColor, cardColor, borderColor);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeading(Payload payload, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        payload.text,
        style: TextStyle(
          fontSize: _getTextSize(payload.textSize ?? '3xl'),
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSubheading(Payload payload, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        payload.text,
        style: TextStyle(
          fontSize: _getTextSize(payload.textSize ?? 'lg'),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildParagraph(Payload payload, bool isDark, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        payload.text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: secondaryTextColor,
        ),
      ),
    );
  }

  Widget _buildBulletList(
      Payload payload,
      bool isDark,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      Color borderColor,
      ) {
    if (payload.items == null || payload.items!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: payload.items!.map((item) {
          // Check if it's a heading item (ends with :)
          if (item.endsWith(':')) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                item,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  double _getTextSize(String size) {
    switch (size) {
      case 'xs':
        return 12;
      case 'sm':
        return 14;
      case 'base':
        return 16;
      case 'lg':
        return 18;
      case 'xl':
        return 20;
      case '2xl':
        return 24;
      case '3xl':
        return 28;
      case '4xl':
        return 32;
      default:
        return 16;
    }
  }
}