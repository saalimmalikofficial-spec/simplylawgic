// lib/screens/notes/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/models/subject_notes.dart';
import 'package:simplylawgic/services/api_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final String slug;

  const NoteDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  SubjectNotes? _note;
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadNoteDetail();
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildNoteContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNoteDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteContent() {
    final note = _note!;
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.white,
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
                        const Color(0xFF6C5CE7),
                        const Color(0xFFA29BFE),
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
              ...note.blocks.map((block) => _renderBlock(block)).toList(),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _renderBlock(Block block) {
    switch (block.type) {
      case 'heading':
        return _buildHeading(block.payload);
      case 'subheading':
        return _buildSubheading(block.payload);
      case 'paragraph':
        return _buildParagraph(block.payload);
      case 'bullet_list':
        return _buildBulletList(block.payload);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeading(Payload payload) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        payload.text,
        style: TextStyle(
          fontSize: _getTextSize(payload.textSize ?? '3xl'),
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSubheading(Payload payload) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        payload.text,
        style: TextStyle(
          fontSize: _getTextSize(payload.textSize ?? 'lg'),
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(Payload payload) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        payload.text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildBulletList(Payload payload) {
    if (payload.items == null || payload.items!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
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
                  color: Colors.black87,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    color: Color(0xFF6C5CE7),
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
                      color: Colors.grey.shade800,
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