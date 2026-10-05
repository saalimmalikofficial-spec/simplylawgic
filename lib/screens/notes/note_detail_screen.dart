// lib/screens/notes/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/screens/notes/detail_pdf_view_screen.dart';
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

  // 🔥 Auto-refresh jab user browser se app pe wapas aaye
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔥 App resumed — refreshing note detail');
      _loadNoteDetail();
    }
  }

  Future<void> _loadNoteDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final note = await _apiService.getSubjectNoteBySlug(widget.slug);
      if (!mounted) return;
      setState(() => _note = note);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // OPEN CHECKOUT (for notes purchase)
  // ============================================================
  Future<void> _openCheckout() async {
    if (_note == null) return;

    final purchaseBlock = _note!.purchaseBlock;
    if (purchaseBlock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Purchase info not available'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    // 🔥 Step 1: Referral code bottom sheet
    final referralCode = await _showReferralCodeSheet();
    if (referralCode == null) {
      debugPrint('❌ User cancelled checkout');
      return;
    }

    if (!mounted) return;

    // 🔥 Step 2: Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final response = await _apiService.createNotesCheckoutSession(
        noteId: _note!.id,
        blockId: purchaseBlock.id,
        referralCode: referralCode.isEmpty ? null : referralCode,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      final checkoutUrl = response['checkoutUrl'] as String?;
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('Invalid checkout URL received');
      }

      debugPrint('✅ Checkout URL: $checkoutUrl');
      debugPrint('   SID: ${response['sid']}');
      debugPrint('   Title: ${response['title']}');
      debugPrint('   Amount: ₹${response['amount']} ${response['currency']}');

      // Open in browser
      final uri = Uri.parse(checkoutUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch payment page');
      }

      // Info snackbar
      if (mounted) {
        final amount = response['amount'] ?? '';
        final currency = response['currency'] ?? 'INR';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Complete payment of ₹$amount $currency in browser. '
                  'Come back after payment.',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ============================================================
  // OPEN PDF IN IN-APP WEBVIEW (naya flow)
  // ============================================================
  Future<void> _openPdf(Block? purchaseBlock) async {
    if (purchaseBlock == null) return;

    final streamPath = purchaseBlock.streamPath;
    if (streamPath == null || streamPath.isEmpty) {
      _showSnack('❌ PDF link not available');
      return;
    }

    // Build full URL
    final directUrl =
        '${ApiService.baseUrl.replaceAll('/api', '')}/api$streamPath';

    // 🔥 Wrap in Google Docs Viewer for better PDF rendering in WebView
    final webViewUrl =
        'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(directUrl)}';

    debugPrint('📖 Opening PDF in WebView: $webViewUrl');

    if (!mounted) return;

    // 🔥 Navigate to detail PDF view screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPdfViewScreen(
          pdfUrl: webViewUrl,
          title: purchaseBlock.payload.pdfOriginalName ?? 'eBook',
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD PDF (opens in external browser for download)
  // ============================================================
  Future<void> _downloadPdf(Block? purchaseBlock) async {
    if (purchaseBlock == null) return;

    final streamPath = purchaseBlock.streamPath;
    if (streamPath == null || streamPath.isEmpty) {
      _showSnack('❌ PDF link not available');
      return;
    }

    final directUrl =
        '${ApiService.baseUrl.replaceAll('/api', '')}/api$streamPath';
    debugPrint('📥 Downloading PDF: $directUrl');

    try {
      final uri = Uri.parse(directUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showSnack('❌ Could not open download link');
      }
    } catch (e) {
      debugPrint('❌ Download error: $e');
      _showSnack('❌ Could not download: $e');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // REFERRAL CODE BOTTOM SHEET
  // ============================================================
  Future<String?> _showReferralCodeSheet() async {
    final TextEditingController controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161622) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Have a Referral Code?',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Apply it to get discount (optional)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white60
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. SAVE20',
                    hintStyle: TextStyle(
                      letterSpacing: 1,
                      fontWeight: FontWeight.normal,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                    prefixIcon: Icon(
                      Icons.confirmation_number_outlined,
                      size: 20,
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(sheetContext, '');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: isDark
                                ? Colors.white70
                                : Colors.grey.shade700,
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            final code = controller.text.trim();
                            Navigator.pop(
                              sheetContext,
                              code.isEmpty ? '' : code,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_open_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Apply & Continue',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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

    // 🔥 Access check
    final canAccess = note.canAccess;

    // Preview / locked split
    final allBlocks = note.blocks;
    final purchaseIdx = allBlocks.indexWhere((b) => b.type == 'pdf_purchase');

    final rawPreview = purchaseIdx == -1
        ? allBlocks
        : allBlocks.sublist(0, purchaseIdx);
    final previewBlocks = rawPreview.take(_freePreviewBlockCount).toList();

    // 🔥 Access hai → no locked blocks
    // 🔥 Access nahi → locked blocks (dimmed)
    final lockedBlocks = canAccess
        ? <Block>[]
        : (purchaseIdx == -1
        ? (rawPreview.length > _freePreviewBlockCount
        ? rawPreview.sublist(_freePreviewBlockCount)
        : <Block>[])
        : allBlocks.sublist(purchaseIdx + 1));

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
                      Row(
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
                          // 🔥 Unlocked badge
                          if (canAccess) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Unlocked',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
              // 🔥 Label — different based on access
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canAccess
                      ? const Color(0xFF10B981).withOpacity(0.12)
                      : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canAccess
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      canAccess
                          ? Icons.menu_book_rounded
                          : Icons.visibility_outlined,
                      size: 14,
                      color: canAccess
                          ? const Color(0xFF10B981)
                          : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      canAccess ? 'FULL CONTENT' : 'FREE PREVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: canAccess
                            ? const Color(0xFF10B981)
                            : Colors.green,
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

              // 🔥 Agar access hai → saare locked blocks normal dikhao
              if (canAccess && lockedBlocks.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...lockedBlocks
                    .map((block) => _renderBlock(
                  block,
                  isDark,
                  textColor,
                  secondaryTextColor,
                  cardColor,
                  borderColor,
                ))
                    .toList(),
              ],

              const SizedBox(height: 24),
            ]),
          ),
        ),

        // ============ LOCKED CONTENT (only if NOT purchased) ============
        if (!canAccess && lockedBlocks.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Stack(
                children: [
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

        // ============ ACCESS CARD (unlocked) or PURCHASE CARD (locked) ============
        if (purchaseBlock != null)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: canAccess
                  ? _buildUnlockedCard(
                purchaseBlock,
                isDark,
                cardColor,
                borderColor,
                textColor,
                secondaryTextColor,
              )
                  : _buildPurchaseCard(
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

  // ============================================================
  // UNLOCKED CARD (after purchase)
  // ============================================================
  Widget _buildUnlockedCard(
      Block purchaseBlock,
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final payload = purchaseBlock.payload;
    final title = payload.title?.isNotEmpty == true
        ? payload.title!
        : 'eBook Access';
    final pdfName = payload.pdfOriginalName?.isNotEmpty == true
        ? payload.pdfOriginalName!
        : 'Your eBook';
    final allowDownload = payload.allowStudentDownload == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F2A1F), const Color(0xFF0A1A12)]
              : [
            const Color(0xFF10B981).withOpacity(0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unlocked badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  'UNLOCKED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pdfName,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // View button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _openPdf(purchaseBlock),
                    icon: const Icon(Icons.visibility_rounded, size: 20),
                    label: const Text(
                      'View eBook',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Download button (if allowed)
              if (allowDownload)
                SizedBox(
                  width: 54,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF10B981),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => _downloadPdf(purchaseBlock),
                    child: const Icon(
                      Icons.download_rounded,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '🔓 Lifetime access • View anytime',
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

  // ============================================================
  // PURCHASE CARD (before purchase)
  // ============================================================
  Widget _buildPurchaseCard(
      Block purchaseBlock,
      bool isDark,
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    final payload = purchaseBlock.payload;

    final title = payload.title?.isNotEmpty == true
        ? payload.title!
        : 'Buy Full Notes';
    final description = payload.description?.isNotEmpty == true
        ? payload.description!
        : 'Get complete access to all chapters, case laws, comparison tables and exam-oriented questions.';
    final price = payload.priceAmount ?? 999;
    final currency = payload.currency ?? 'INR';

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
              if (payload.viewOnlyInBrowser == true)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // Buy button
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
              onPressed: _openCheckout,
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

  Widget _buildImageBlock(Payload payload, bool isDark, Color borderColor) {
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