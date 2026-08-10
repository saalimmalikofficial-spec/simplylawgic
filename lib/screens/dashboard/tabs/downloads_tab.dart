// lib/screens/dashboard/tabs/downloads_tab.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/utils/app_colors.dart';

enum DownloadFileType { pdf, video, doc }

// TODO: move to lib/models/download_item.dart once downloads have a real
// backend/local-storage layer — this is a placeholder model for now,
// same pattern TestSeries follows in models/test_series.dart.
class DownloadItem {
  final String id;
  final String title;
  final String category; // e.g. "Major Laws", "Minor Laws", "Judiciary Prep"
  final DownloadFileType type;
  final double sizeMb;
  final DateTime downloadedAt;

  const DownloadItem({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.sizeMb,
    required this.downloadedAt,
  });
}

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({super.key});

  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  // TODO: replace with real downloaded-files data once download
  // persistence (local storage / DB query) is wired up.
  final List<DownloadItem> _downloads = [
    DownloadItem(
      id: '1',
      title: 'Indian Penal Code — Key Sections & Case Law.pdf',
      category: 'Major Laws',
      type: DownloadFileType.pdf,
      sizeMb: 4.2,
      downloadedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DownloadItem(
      id: '2',
      title: 'CrPC Lecture 08 — Bail Provisions.mp4',
      category: 'Major Laws',
      type: DownloadFileType.video,
      sizeMb: 86.5,
      downloadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    DownloadItem(
      id: '3',
      title: 'Limitation Act — Quick Revision Notes.docx',
      category: 'Minor Laws',
      type: DownloadFileType.doc,
      sizeMb: 1.1,
      downloadedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DownloadItem(
      id: '4',
      title: 'Judiciary Master Batch — Answer Writing Guide.pdf',
      category: 'Judiciary Prep',
      type: DownloadFileType.pdf,
      sizeMb: 2.8,
      downloadedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  double get _totalSizeMb => _downloads.fold(0, (sum, d) => sum + d.sizeMb);

  ({IconData icon, Color color}) _iconFor(DownloadFileType type) {
    switch (type) {
      case DownloadFileType.pdf:
        return (icon: Icons.picture_as_pdf_rounded, color: const Color(0xFFE53935));
      case DownloadFileType.video:
        return (icon: Icons.play_circle_fill_rounded, color: AppColors.primary);
      case DownloadFileType.doc:
        return (icon: Icons.description_rounded, color: const Color(0xFF1E88E5));
    }
  }

  String _formatSize(double mb) =>
      mb >= 1000 ? '${(mb / 1000).toStringAsFixed(1)} GB' : '${mb.toStringAsFixed(1)} MB';

  String _formatDate(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  Future<bool> _confirmDelete(DownloadItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 16, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Remove download?', style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
        content: Text(
          '"${item.title}" will be removed from your device. You can download it again anytime.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _removeDownload(DownloadItem item) {
    final index = _downloads.indexOf(item);
    setState(() => _downloads.remove(item));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${item.title}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _downloads.insert(index.clamp(0, _downloads.length), item)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: true,
        bottom: false,
        child: _downloads.isEmpty ? _buildEmptyView() : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _StorageHeroCard(
              fileCount: _downloads.length,
              totalSizeMb: _totalSizeMb,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          sliver: SliverList.builder(
            itemCount: _downloads.length,
            itemBuilder: (context, i) => _buildDownloadTile(_downloads[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadTile(DownloadItem item) {
    final iconData = _iconFor(item.type);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(item),
      onDismissed: (_) => _removeDownload(item),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: iconData.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: iconData.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(iconData.icon, color: iconData.color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _MetaPill(text: item.category, color: iconData.color),
                                const SizedBox(width: 6),
                                Text(
                                  '${_formatSize(item.sizeMb)} · ${_formatDate(item.downloadedAt)}',
                                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 21),
                        onPressed: () async {
                          if (await _confirmDelete(item)) _removeDownload(item);
                        },
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

  Widget _buildEmptyView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 40),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.download_done_rounded, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'No Downloads Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'PDFs, notes and videos you download for offline access will show up here',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Gradient hero card summarizing total downloaded files and space used.
class _StorageHeroCard extends StatelessWidget {
  final int fileCount;
  final double totalSizeMb;

  const _StorageHeroCard({required this.fileCount, required this.totalSizeMb});

  @override
  Widget build(BuildContext context) {
    const capMb = 500.0;
    final progress = (totalSizeMb / capMb).clamp(0.0, 1.0);
    final sizeLabel = totalSizeMb >= 1000 ? '${(totalSizeMb / 1000).toStringAsFixed(1)} GB' : '${totalSizeMb.toStringAsFixed(1)} MB';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.78)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OFFLINE LIBRARY',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  '$fileCount ${fileCount == 1 ? 'file' : 'files'} saved',
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sizeLabel used offline',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 62,
                  height: 62,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: Colors.white.withOpacity(0.22),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const Icon(Icons.folder_rounded, color: Colors.white, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny category label pill next to the size/date meta line.
class _MetaPill extends StatelessWidget {
  final String text;
  final Color color;
  const _MetaPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}