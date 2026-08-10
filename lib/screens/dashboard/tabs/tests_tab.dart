// lib/screens/dashboard/tabs/tests_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simplylawgic/screens/dashboard/tabs/test_series_detail_screen.dart';
import 'package:simplylawgic/services/api_service.dart';
import 'package:simplylawgic/models/test_series.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class TestsTab extends StatefulWidget {
  const TestsTab({super.key});

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

  // Debounced so filtering doesn't run on every single keystroke.
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _filterTests);
  }

  void _filterTests() {
    if (!mounted) return;
    setState(() {
      String query = _searchQuery.toLowerCase().trim();

      _filteredTests = _testSeries.where((test) {
        // Search filter
        bool matchesSearch = query.isEmpty ||
            test.title.toLowerCase().contains(query) ||
            test.subjectName.toLowerCase().contains(query) ||
            test.description.toLowerCase().contains(query);

        // Category filter
        bool matchesCategory = true;
        if (_selectedFilter == 'Major Laws') {
          matchesCategory = test.subjectCategory == 'Major Laws';
        } else if (_selectedFilter == 'Minor Laws') {
          matchesCategory = test.subjectCategory == 'Minor Laws';
        }

        // Price filter
        bool matchesPrice = true;
        if (_selectedFilter == 'Free') {
          matchesPrice = !test.isPaid;
        } else if (_selectedFilter == 'Paid') {
          matchesPrice = test.isPaid;
        }

        // Popular filter
        bool matchesPopular = true;
        if (_selectedFilter == 'Popular') {
          matchesPopular = test.tags.any((tag) =>
          tag.toLowerCase() == 'popular'
          );
        }

        return matchesSearch && matchesCategory && matchesPrice && matchesPopular;
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
    // No nested Scaffold — this tab already lives inside the dashboard's
    // Scaffold (bottom nav). RefreshIndicator wraps the content directly.
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadTestSeries,
      child: Container(
        color: AppColors.background,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
            ? _buildErrorView()
            : _testSeries.isEmpty
            ? _buildEmptyView()
            : Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: _filteredTests.isEmpty
                  ? _buildNoResultsView()
                  : _buildTestList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search test series...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.textSecondary),
            onPressed: _clearSearch,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.6),
          ),
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final popularCount = _testSeries.where((t) =>
        t.tags.any((tag) => tag.toLowerCase() == 'popular')
    ).length;

    final filters = ['All', 'Popular', 'Major Laws', 'Minor Laws', 'Free', 'Paid'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;

            Color getChipColor() {
              if (filter == 'Popular' && isSelected) {
                return Colors.orange.shade600;
              }
              return isSelected ? AppColors.primary : Colors.white;
            }

            Color getTextColor() {
              if (isSelected) {
                return Colors.white;
              }
              return AppColors.textSecondary;
            }

            IconData? getIcon() {
              if (filter == 'Popular') {
                return Icons.star;
              }
              return null;
            }

            String getLabel() {
              if (filter == 'Popular') {
                return 'Popular ($popularCount)';
              }
              return filter;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                showCheckmark: false, // custom color/icon already signal selection
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (getIcon() != null) ...[
                      Icon(
                        getIcon(),
                        size: 16,
                        color: getTextColor(),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      getLabel(),
                      style: TextStyle(
                        color: getTextColor(),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  _filterTests();
                },
                backgroundColor: Colors.white,
                selectedColor: getChipColor(),
                side: BorderSide(
                  color: isSelected
                      ? (filter == 'Popular' ? Colors.orange.shade600 : AppColors.primary)
                      : AppColors.border,
                  width: isSelected ? 1.6 : 1,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected
                        ? (filter == 'Popular' ? Colors.orange.shade600 : AppColors.primary)
                        : AppColors.border,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No Results Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filter',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _clearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTestSeries,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No Tests Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new test series',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTests.length,
      itemBuilder: (context, index) {
        final test = _filteredTests[index];
        return TestCard(
          key: ValueKey(test.slug),
          test: test,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestSeriesDetailScreen(slug: test.slug),
              ),
            );
          },
        );
      },
    );
  }
}

/// Small pill/badge used for category, popular and test-count tags.
/// Pulled out of TestCard so the same badge styling isn't rebuilt three
/// times with slightly different padding/decoration each time.
class _Badge extends StatelessWidget {
  final Widget? icon;
  final String text;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;

  const _Badge({
    required this.text,
    required this.color,
    this.icon,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// Test Card Widget
class TestCard extends StatelessWidget {
  final TestSeries test;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.test,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getCategoryColor(String category) {
      switch (category.toLowerCase()) {
        case 'major laws':
          return AppColors.primary;
        case 'minor laws':
          return const Color(0xFF00B894);
        default:
          return AppColors.primary;
      }
    }

    final isPopular = test.tags.any((tag) => tag.toLowerCase() == 'popular');
    final categoryColor = getCategoryColor(test.subjectCategory);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: test.coverImageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(test.coverImageUrl),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                )
                    : null,
              ),
              child: test.coverImageUrl.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 48, color: categoryColor),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        test.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Badge(
                        text: test.subjectCategory.toUpperCase(),
                        color: categoryColor,
                      ),
                      const Spacer(),
                      if (isPopular) ...[
                        _Badge(
                          text: 'Popular',
                          color: Colors.orange.shade700,
                          backgroundColor: Colors.orange.shade50,
                          borderColor: Colors.orange.shade200,
                          icon: Icon(Icons.star, size: 12, color: Colors.orange.shade700),
                        ),
                        const SizedBox(width: 8),
                      ],
                      _Badge(
                        text: '${test.testCount} Tests',
                        color: Colors.blue.shade700,
                        backgroundColor: Colors.blue.shade50,
                        icon: Icon(Icons.quiz, size: 14, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    test.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (test.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: test.tags.map((tag) {
                        if (tag.toLowerCase() == 'popular') return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          test.isPaid
                              ? '₹${test.priceAmount} ${test.currency}'
                              : 'FREE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: test.isPaid
                                ? AppColors.primary
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed: onTap,
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}