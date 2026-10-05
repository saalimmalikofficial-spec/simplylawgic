// your_purchase_screen.dart

import 'package:flutter/material.dart';
import 'package:simplylawgic/models/purchaseItem.dart';
import 'package:simplylawgic/screens/test/test_series_detail_screen.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'webview_see_notes_screen.dart';

class YourPurchaseScreen extends StatefulWidget {
  const YourPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<YourPurchaseScreen> createState() => _YourPurchaseScreenState();
}

class _YourPurchaseScreenState extends State<YourPurchaseScreen> {
  final ApiService _api = ApiService();

  late Future<PurchasesResponse> _future;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _future = _api.getMyPurchases();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.getMyPurchases();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text('My Purchases'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<PurchasesResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;
          final filtered = _applyFilter(data.items);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _CountsHeader(counts: data.counts)),
                SliverToBoxAdapter(
                  child: _FilterTabs(
                    selected: _selectedFilter,
                    onChanged: (v) => setState(() => _selectedFilter = v),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No purchases found')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PurchaseCard(item: filtered[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PurchaseItem> _applyFilter(List<PurchaseItem> items) {
    switch (_selectedFilter) {
      case 'notes':
        return items.where((e) => e.isNotes).toList();
      case 'test-series':
        return items.where((e) => e.isTestSeries).toList();
      default:
        return items;
    }
  }
}

// ═════════════════════════════════════════════════════════════
// WIDGETS (same as before)
// ═════════════════════════════════════════════════════════════

class _CountsHeader extends StatelessWidget {
  final PurchaseCounts counts;
  const _CountsHeader({required this.counts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _CountChip(label: 'Notes', value: counts.notes),
          const SizedBox(width: 8),
          _CountChip(label: 'Tests', value: counts.tests),
          const SizedBox(width: 8),
          _CountChip(label: 'Test Series', value: counts.testSeries),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int value;
  const _CountChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'key': 'all', 'label': 'All'},
      {'key': 'notes', 'label': 'Notes'},
      {'key': 'test-series', 'label': 'Test Series'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selected == tab['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab['label']!),
              selected: isSelected,
              onSelected: (_) => onChanged(tab['key']!),
              selectedColor: Colors.black87,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final PurchaseItem item;
  const _PurchaseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (item.isNotes) {
          final path = item.accessPath ?? '';
          if (path.isEmpty) {
            _snack(context, 'Notes link not available');
            return;
          }

          final fullUrl = path.startsWith('http')
              ? path
              : 'https://simplylawgic.com${path.startsWith('/') ? '' : '/'}$path';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebViewSeeNotesScreen(
                url: fullUrl,
                title: item.subtitle,
              ),
            ),
          );
          return;
        }

        if (item.isTestSeries) {
          final slug = item.slug;
          if (slug.isEmpty) {
            _snack(context, 'Test series slug missing');
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TestSeriesDetailScreen(slug: slug),
            ),
          );
          return;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 56,
                height: 56,
                color: const Color(0xFFEFF1F5),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _typeIcon(item),
                )
                    : _typeIcon(item),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TypeBadge(item: item),
                      const Spacer(),
                      Text(
                        item.amountLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(item.purchasedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (item.unlocked)
                        Row(
                          children: [
                            Icon(Icons.lock_open,
                                size: 12, color: Colors.green.shade600),
                            const SizedBox(width: 3),
                            Text(
                              'Unlocked',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _typeIcon(PurchaseItem item) {
    return Icon(
      item.isTestSeries ? Icons.quiz_outlined : Icons.menu_book_outlined,
      color: Colors.grey.shade600,
      size: 26,
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final PurchaseItem item;
  const _TypeBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final isTest = item.isTestSeries;
    final color = isTest ? Colors.orange.shade700 : Colors.blue.shade700;
    final bg = isTest ? Colors.orange.shade50 : Colors.blue.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isTest ? 'TEST SERIES' : 'NOTES',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}