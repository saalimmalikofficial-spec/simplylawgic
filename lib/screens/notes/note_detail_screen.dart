// lib/screens/notes/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with WidgetsBindingObserver {
  SubjectNotes? _note;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDark = false;
  final ApiService _apiService = ApiService();

  // 👇 Website URL for purchase
  static const String _websiteUrl = 'https://simplylawgic.com/';

  // 👇 Kitne preview blocks free dikhane hain (baaki locked)
  static const int _freePreviewBlockCount = 4;

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
        setState(() => _isDark = isDark);
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
      setState(() => _note = note);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============ OPEN WEBSITE (for purchase) ============
  Future<void> _openWebsite() async {
    final Uri url = Uri.parse(_websiteUrl);

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // opens in browser
      );
      if (!launched) {
        throw Exception('Could not launch $_websiteUrl');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Could not open website: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
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
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200;
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
          : _buildNoteContent(
        isDark,
        textColor,
        secondaryTextColor,
        cardColor,
        borderColor,
        appBarColor,
      ),
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

    // 👇 Preview / locked split
    final allBlocks = note.blocks;
    final purchaseIdx = allBlocks.indexWhere((b) => b.type == 'pdf_purchase');

    final rawPreview = purchaseIdx == -1
        ? allBlocks
        : allBlocks.sublist(0, purchaseIdx);
    final previewBlocks = rawPreview.take(_freePreviewBlockCount).toList();

    final lockedBlocks = purchaseIdx == -1
        ? (rawPreview.length > _freePreviewBlockCount
        ? rawPreview.sublist(_freePreviewBlockCount)
        : <Block>[])
        : allBlocks.sublist(purchaseIdx + 1);

    final purchaseBlock = note.purchaseBlock;

    return CustomScrollView(
      slivers: [
        // ============ Custom App Bar ============
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
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
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
                      if (note.tagline.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          note.tagline,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ============ FREE PREVIEW SECTION ============
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Preview label
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.visibility_outlined,
                        size: 14, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      'FREE PREVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Preview blocks
              ...previewBlocks
                  .map((block) => _renderBlock(
                block,
                isDark,
                textColor,
                secondaryTextColor,
                cardColor,
                borderColor,
              ))
                  .toList(),

              const SizedBox(height: 24),
            ]),
          ),
        ),

        // ============ LOCKED CONTENT (dimmed + fade) ============
        if (lockedBlocks.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Locked content (dimmed)
                  Opacity(
                    opacity: 0.35,
                    child: Column(
                      children: lockedBlocks
                          .take(3)
                          .map((block) => _renderBlock(
                        block,
                        isDark,
                        textColor,
                        secondaryTextColor,
                        cardColor,
                        borderColor,
                      ))
                          .toList(),
                    ),
                  ),
                  // Fade gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (isDark ? const Color(0xFF0A0A0F) : Colors.white)
                                .withOpacity(0.4),
                            (isDark ? const Color(0xFF0A0A0F) : Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ============ PURCHASE CTA CARD ============
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _buildPurchaseCard(
              purchaseBlock,
              isDark,
              cardColor,
              borderColor,
              textColor,
              secondaryTextColor,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  // ============ PURCHASE CARD ============
  Widget _buildPurchaseCard(
      Block? purchaseBlock,
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final payload = purchaseBlock?.payload;

    final title = payload?.title?.isNotEmpty == true
        ? payload!.title!
        : 'Buy Full Notes';
    final description = payload?.description?.isNotEmpty == true
        ? payload!.description!
        : 'Get complete access to all chapters, case laws, comparison tables and exam-oriented questions.';
    final price = payload?.priceAmount ?? 999;
    final currency = payload?.currency ?? 'INR';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF0F0F1A)]
              : [AppColors.primary.withOpacity(0.08), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.25),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lock icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 18),

          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$price',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  currency,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ),
              const Spacer(),
              if (payload?.viewOnlyInBrowser == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'View in Browser',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // 👇 Buy button → opens website
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _openWebsite,
              icon: const Icon(Icons.shopping_bag_outlined, size: 20),
              label: const Text(
                'Unlock Full Access',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Center(
            child: Text(
              '🔒 Instant access • Downloadable PDF • Lifetime use',
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ BLOCK RENDERER ============
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
      case 'numbered_list':
        return _buildBulletList(block.payload, isDark, textColor,
            secondaryTextColor, cardColor, borderColor);
      case 'image':
        return _buildImageBlock(block.payload, isDark, borderColor);
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

  Widget _buildParagraph(
      Payload payload, bool isDark, Color secondaryTextColor) {
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

  Widget _buildImageBlock(
      Payload payload, bool isDark, Color borderColor) {
    final images = payload.images;
    if (images == null || images.isEmpty) {
      if (payload.url == null || payload.url!.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            payload.url!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    // Carousel (horizontal scroll)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final img = images[i];
            final url = img['url']?.toString() ?? '';
            if (url.isEmpty) return const SizedBox.shrink();
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 160,
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            );
          },
        ),
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