// lib/screens/dashboard/tabs/tests_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simplylawgic/screens/test/test_series_detail_screen.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/models/test_series.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class TestsTab extends StatefulWidget {
  final bool showBackButton;
  const TestsTab({super.key, this.showBackButton = true});

  @override
  State<TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<TestsTab> {
  List<TestSeries> _testSeries = [];
  List<TestSeries> _filteredTests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadTestSeries();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTestSeries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tests = await _apiService.getTestSeries();
      setState(() {
        _testSeries = tests;
        _filteredTests = tests;
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

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _filterTests);
  }

  void _filterTests() {
    if (!mounted) return;
    setState(() {
      final query = _searchQuery.toLowerCase().trim();

      _filteredTests = _testSeries.where((test) {
        final matchesSearch = query.isEmpty ||
            test.title.toLowerCase().contains(query) ||
            test.subjectName.toLowerCase().contains(query) ||
            test.description.toLowerCase().contains(query);

        bool matchesCategory = true;
        if (_selectedFilter == 'Major Laws') {
          matchesCategory = test.subjectCategory == 'Major Laws';
        } else if (_selectedFilter == 'Minor Laws') {
          matchesCategory = test.subjectCategory == 'Minor Laws';
        }

        bool matchesPrice = true;
        if (_selectedFilter == 'Free') {
          matchesPrice = !test.isPaid;
        } else if (_selectedFilter == 'Paid') {
          matchesPrice = test.isPaid;
        }

        bool matchesPopular = true;
        if (_selectedFilter == 'Popular') {
          matchesPopular =
              test.tags.any((tag) => tag.toLowerCase() == 'popular');
        }

        return matchesSearch &&
            matchesCategory &&
            matchesPrice &&
            matchesPopular;
      }).toList();
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilter = 'All';
      _filteredTests = _testSeries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.bg;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : AppColors.background;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;
    final shadowColor =
    isDark ? Colors.white.withOpacity(0.03) : AppColors.cardShadow;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: widget.showBackButton
          ? AppBar(
        backgroundColor:
        isDark ? const Color(0xFF12121E) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Test Series',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
        centerTitle: true,
      )
          : null,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadTestSeries,
        child: Container(
          color: backgroundColor,
          child: _isLoading
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
              : _testSeries.isEmpty
              ? _buildEmptyView(isDark, secondaryTextColor)
              : Column(
            children: [
              _buildHeaderSection(isDark, borderColor, cardColor,
                  secondaryTextColor),
              Expanded(
                child: _filteredTests.isEmpty
                    ? _buildNoResultsView(
                    isDark, secondaryTextColor)
                    : _buildTestList(
                    isDark,
                    cardColor,
                    borderColor,
                    shadowColor,
                    textColor,
                    secondaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark, Color borderColor, Color cardColor,
      Color secondaryTextColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          _buildSearchBar(isDark, borderColor, secondaryTextColor),
          _buildFilterChips(isDark, borderColor, secondaryTextColor),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
      bool isDark, Color borderColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0A0F) : AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search test series, subjects...',
            hintStyle: TextStyle(
              color:
              isDark ? Colors.white.withOpacity(0.3) : AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color:
              isDark ? Colors.white.withOpacity(0.3) : AppColors.textMuted,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.cancel_rounded,
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : AppColors.textMuted,
                size: 18,
              ),
              onPressed: _clearSearch,
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
      bool isDark, Color borderColor, Color secondaryTextColor) {
    final filters = [
      'All',
      'Popular',
      'Major Laws',
      'Minor Laws',
      'Free',
      'Paid'
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
                _filterTests();
              },
              selectedColor: filter == 'Popular'
                  ? Colors.amber.shade700
                  : AppColors.primary,
              backgroundColor: isDark ? const Color(0xFF0A0A0F) : AppColors.bg,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? (filter == 'Popular'
                    ? Colors.amber.shade700
                    : AppColors.primary)
                    : borderColor,
              ),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestList(bool isDark, Color cardColor, Color borderColor,
      Color shadowColor, Color textColor, Color secondaryTextColor) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredTests.length,
      itemBuilder: (context, index) {
        final test = _filteredTests[index];
        return TestCard(
          key: ValueKey(test.slug),
          test: test,
          isDark: isDark,
          cardColor: cardColor,
          borderColor: borderColor,
          shadowColor: shadowColor,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute( builder: (context) => TestSeriesDetailScreen(slug: test.slug),),
            );
          },
          //
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => TestSeriesDetailScreen(slug: test.slug),
          //     ),
          //   );
          // },
        );
      },
    );
  }

  Widget _buildNoResultsView(bool isDark, Color secondaryTextColor) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color:
                isDark ? Colors.white.withOpacity(0.3) : AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'No Match Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching with a different keyword or filter',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _clearSearch,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Reset Search'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
          child: Column(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTestSeries,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(bool isDark, Color secondaryTextColor) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color:
                isDark ? Colors.white.withOpacity(0.3) : AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'No Test Series Available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Check back later for newly published test modules',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TEST CARD (same as before)
// ============================================================
class TestCard extends StatelessWidget {
  final TestSeries test;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.test,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  String _capitalizeTitle(String title) {
    return title.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.length >= 2 &&
          word == word.toUpperCase() &&
          RegExp(r'^[A-Z]+$').hasMatch(word)) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final isPopular = test.tags.any((tag) => tag.toLowerCase() == 'popular');

    final effectiveCardColor = isDark ? const Color(0xFF12131C) : Colors.white;
    final effectiveBorderColor =
    isDark ? const Color(0xFF26293B) : const Color(0xFFEAECF0);
    final placeholderBg =
    isDark ? const Color(0xFF0D0E15) : const Color(0xFFF8F9FA);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: effectiveCardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: effectiveBorderColor, width: 1),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(9)),
                child: AspectRatio(
                  aspectRatio: 2.8 / 1,
                  child: Container(
                    width: double.infinity,
                    color: placeholderBg,
                    child: test.coverImageUrl.isNotEmpty
                        ? Image.network(
                      test.coverImageUrl,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _buildPlaceholderHeader(placeholderBg),
                    )
                        : _buildPlaceholderHeader(placeholderBg),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Badge(
                          text: test.subjectCategory.toUpperCase(),
                          color: AppColors.primary,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ),
                        const Spacer(),
                        if (isPopular) ...[
                          _Badge(
                            text: 'POPULAR',
                            color: const Color(0xFFD97706),
                            backgroundColor: const Color(0xFFFEF3C7),
                            icon: const Icon(Icons.star_rounded,
                                size: 10, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(width: 4),
                        ],
                        _Badge(
                          text: '${test.testCount} TESTS',
                          color: AppColors.secondary,
                          backgroundColor:
                          AppColors.secondary.withOpacity(0.1),
                          icon: Icon(Icons.assignment_outlined,
                              size: 10, color: AppColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _capitalizeTitle(test.title),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: textColor,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            test.subjectName,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (test.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: test.tags
                            .where((t) => t.toLowerCase() != 'popular')
                            .map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A1C29)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isDark ? Colors.white38 : Colors.black45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              test.isPaid ? '₹${test.priceAmount}' : 'FREE',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: test.isPaid
                                    ? AppColors.primary
                                    : AppColors.secondary,
                              ),
                            ),
                            if (test.isPaid && test.currency.isNotEmpty) ...[
                              const SizedBox(width: 2),
                              Text(
                                test.currency,
                                style: TextStyle(
                                  fontSize: 9,
                                  color:
                                  isDark ? Colors.white38 : Colors.black45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ]
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 11, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderHeader(Color bgColor) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded,
                size: 28, color: AppColors.primary.withOpacity(0.4)),
            const SizedBox(height: 2),
            Text(
              test.subjectName,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final Widget? icon;
  final String text;
  final Color color;
  final Color backgroundColor;

  const _Badge({
    required this.text,
    required this.color,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 2)],
          Text(
            text,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}