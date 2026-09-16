// lib/screens/user_progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/analytics_model.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/route_observer.dart';
import '../services/student_notifier.dart';   // 🔥 NEW

/// Centralized colors
class _AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const purple = Color(0xFF8B5CF6);
  static const teal = Color(0xFF0D9488);
  static const orange = Color(0xFFF97316);
  static const indigo = Color(0xFF6366F1);
  static const skipped = Color(0xFF94A3B8);
  static const pink = Color(0xFFEC4899);
  static const gold = Color(0xFFF59E0B);
}

class UserProgressScreen extends StatefulWidget {
  const UserProgressScreen({super.key});

  @override
  State<UserProgressScreen> createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  AnalyticsData? _analyticsData;
  Student? _student;
  bool _isLoading = true;
  String? _errorMessage;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    // 🔥🔥🔥 GLOBAL NOTIFIER LISTENER
    StudentNotifier.instance.student.addListener(_onStudentChanged);

    _fetchAnalytics();
  }

  // 🔥 Notifier change hone pe student update
  void _onStudentChanged() {
    if (!mounted) return;
    final updated = StudentNotifier.instance.student.value;
    if (updated != null) {
      setState(() => _student = updated);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // 🔥 Listener remove
    StudentNotifier.instance.student.removeListener(_onStudentChanged);

    routeObserver.unsubscribe(this);
    _entranceController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _refreshStudentOnly();
  }

  Future<void> _refreshStudentOnly() async {
    try {
      final local = await _storage.getStudent();
      if (mounted && local != null) {
        setState(() => _student = local);
        StudentNotifier.instance.update(local);
      }
    } catch (e) {
      debugPrint('Refresh student error: $e');
    }
  }

  // ============================================================
  // 🔥 FETCH — local + API + notifier
  // ============================================================
  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _entranceController.reset();

    try {
      final localStudent = await _storage.getStudent();
      if (mounted) {
        setState(() => _student = localStudent);
        if (localStudent != null) {
          StudentNotifier.instance.update(localStudent);
        }
      }

      final data = await _apiService.getStudentAnalytics(limit: 50);

      final profileJson = data['profile'];
      if (profileJson is Map<String, dynamic>) {
        final student = Student.fromJson(profileJson);
        await _storage.saveStudent(student);
        if (mounted) {
          setState(() => _student = student);
          StudentNotifier.instance.update(student);
        }
      }

      if (mounted) {
        setState(() {
          _analyticsData = AnalyticsData.fromJson(data);
          _isLoading = false;
        });
        _entranceController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF07070C) : const Color(0xFFFBFCFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (!isDark) _buildTopBlobs(),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading
                  ? _buildSkeletonLoader(
                  key: const ValueKey('loading'), isDark: isDark)
                  : _errorMessage != null
                  ? _buildErrorWidget(isDark)
                  : _analyticsData == null
                  ? _buildEmptyState(isDark)
                  : RefreshIndicator(
                key: const ValueKey('content'),
                onRefresh: _fetchAnalytics,
                color: isDark
                    ? Colors.white
                    : _AppColors.primary,
                backgroundColor: isDark
                    ? const Color(0xFF1A1A2E)
                    : Colors.white,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: _buildContent(isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBlobs() {
    return Positioned(
      top: -60,
      left: -40,
      right: -40,
      child: IgnorePointer(
        child: Container(
          height: 320,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.1, -0.3),
              radius: 1.1,
              colors: [Color(0xFFDCE7FF), Color(0xFFF7FAFF)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================
  Widget _buildContent(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTopBar(isDark),
          const SizedBox(height: 22),

          _buildProfileCard(isDark),
          const SizedBox(height: 22),

          _buildStatsRow(isDark),
          const SizedBox(height: 20),

          _buildQuickActions(isDark),
          const SizedBox(height: 20),

          _buildStreakBanner(isDark),
          const SizedBox(height: 26),

          Align(
            alignment: Alignment.centerLeft,
            child: _buildQuestionBreakdown(isDark),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildScoreTrend(isDark),
          ),
          const SizedBox(height: 18),
          if (_analyticsData!.insights.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: _buildInsights(isDark),
            ),
            const SizedBox(height: 18),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: _buildCategoryPerformance(isDark),
          ),
          const SizedBox(height: 18),
          if (_analyticsData!.retakeProgress.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: _buildRetakeProgress(isDark),
            ),
            const SizedBox(height: 18),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: _buildRecentAttempts(isDark),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildSeriesPerformance(isDark),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================
  Widget _buildTopBar(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Row(
      children: [
        _circleIconButton(
          icon: Icons.menu_rounded,
          bg: cardColor,
          iconColor: iconColor,
          onTap: () {
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold != null && scaffold.hasDrawer) {
              scaffold.openDrawer();
            }
          },
        ),
        const Spacer(),
        _circleIconButton(
          icon: Icons.search_rounded,
          bg: cardColor,
          iconColor: iconColor,
          onTap: () {},
        ),
        const SizedBox(width: 10),
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required Color bg,
    required Color iconColor,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          width: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, color: iconColor, size: 22)),
              if (showDot)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: bg, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================
  Widget _buildProfileCard(bool isDark) {
    final name = _student?.name ?? 'Student';
    final examLabel = _student?.preparingForExamLabel ?? 'Law Learner';
    final avatarUrl = _student?.avatarUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : const Color(0xFF2563EB).withOpacity(0.14),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? Image.network(
                    avatarUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _buildInitialAvatar(name, isDark);
                    },
                    errorBuilder: (_, __, ___) =>
                        _buildInitialAvatar(name, isDark),
                  )
                      : _buildInitialAvatar(name, isDark),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF07070C) : Colors.white,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        Text(
          examLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),

        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? _AppColors.primary.withOpacity(0.16)
                  : const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 14,
                  color: _AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : _AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialAvatar(String name, bool isDark) {
    return Container(
      width: 102,
      height: 102,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _AppColors.primary.withOpacity(0.18),
            _AppColors.purple.withOpacity(0.18),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : _AppColors.primary,
        ),
      ),
    );
  }

  // ============================================================
  // STATS ROW
  // ============================================================
  Widget _buildStatsRow(bool isDark) {
    final summary = _analyticsData!.summary;

    final stats = [
      _StatData(
        label: 'Notes Read',
        value: summary.bookmarkCount,
        suffix: '',
        icon: Icons.menu_book_rounded,
        color: _AppColors.primary,
      ),
      _StatData(
        label: 'Tests Attempted',
        value: summary.submittedAttemptsCount,
        suffix: '',
        icon: Icons.check_circle_rounded,
        color: _AppColors.success,
      ),
      _StatData(
        label: 'Accuracy',
        value: summary.accuracy.round(),
        suffix: '%',
        icon: Icons.star_rounded,
        color: _AppColors.warning,
      ),
      _StatData(
        label: 'Day Streak',
        value: summary.studyStreakDays,
        suffix: '',
        icon: Icons.bar_chart_rounded,
        color: _AppColors.purple,
      ),
    ];

    final cardColor = isDark ? const Color(0xFF16172B) : Colors.white;
    final dividerColor =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEEF1F7);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(stats.length * 2 - 1, (i) {
          if (i.isOdd) {
            return SizedBox(
              height: 44,
              child:
              VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            );
          }
          final data = stats[i ~/ 2];
          return Expanded(child: _buildStatCell(data, isDark));
        }),
      ),
    );
  }

  Widget _buildStatCell(_StatData data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: data.color.withOpacity(isDark ? 0.2 : 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(data.icon, color: data.color, size: 15),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: data.value),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, val, _) => Text(
            '$val${data.suffix}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================
  Widget _buildQuickActions(bool isDark) {
    final actions = [
      _ActionData(
        title: 'My Notes',
        subtitle: 'View & Organize',
        icon: Icons.menu_book_rounded,
        color: _AppColors.primary,
        bgLight: const Color(0xFFE7EFFE),
        bgDark: const Color(0xFF16223F),
      ),
      _ActionData(
        title: 'My Tests',
        subtitle: 'Attempt & Analyze',
        icon: Icons.description_rounded,
        color: _AppColors.success,
        bgLight: const Color(0xFFE4F7EE),
        bgDark: const Color(0xFF123425),
      ),
      _ActionData(
        title: 'Downloads',
        subtitle: 'Offline Access',
        icon: Icons.download_rounded,
        color: _AppColors.purple,
        bgLight: const Color(0xFFEFE9FE),
        bgDark: const Color(0xFF241A3D),
      ),
      _ActionData(
        title: 'Bookmarks',
        subtitle: 'Saved Content',
        icon: Icons.favorite_rounded,
        color: _AppColors.orange,
        bgLight: const Color(0xFFFDEDE2),
        bgDark: const Color(0xFF3A2416),
      ),
    ];

    return Row(
      children: List.generate(actions.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 5,
              right: i == actions.length - 1 ? 0 : 5,
            ),
            child: _buildActionCard(actions[i], isDark),
          ),
        );
      }),
    );
  }

  Widget _buildActionCard(_ActionData data, bool isDark) {
    final cardBg = isDark ? data.bgDark : data.bgLight;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 13, 11, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(data.icon, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: data.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STREAK BANNER
  // ============================================================
  Widget _buildStreakBanner(bool isDark) {
    final testsLeft = 3;
    final moduleName = 'Criminal Law Module';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B33),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1B33).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.adjust_rounded,
              color: Color(0xFFFBBF24),
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keep Going!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You\'re $testsLeft tests away from completing $moduleName',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.white70,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: Color(0xFF0F172A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION BREAKDOWN
  // ============================================================
  Widget _buildQuestionBreakdown(bool isDark) {
    final cardColor = isDark ? const Color(0xFF16172B) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF64748B);

    final breakdown = _analyticsData!.questionBreakdown;
    final total = breakdown.total;
    final double correctRatio = total > 0 ? breakdown.correct / total : 0;
    final double wrongRatio = total > 0 ? breakdown.wrong / total : 0;
    final double skippedRatio = total > 0 ? breakdown.skipped / total : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Question Breakdown', textColor,
              trailing: 'Total: $total', trailingColor: secondaryTextColor),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: total == 0
                  ? Container(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFF1F5F9))
                  : LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final correctW = w * correctRatio;
                  final wrongW = w * wrongRatio;
                  final skippedW = (w - correctW - wrongW).clamp(0.0, w);
                  return Row(
                    children: [
                      Container(
                          width: correctW, color: _AppColors.success),
                      Container(width: wrongW, color: _AppColors.danger),
                      Container(
                          width: skippedW, color: _AppColors.skipped),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendBadge('Correct', '${breakdown.correct}',
                  _AppColors.success, secondaryTextColor, textColor),
              _buildLegendBadge('Wrong', '${breakdown.wrong}',
                  _AppColors.danger, secondaryTextColor, textColor),
              _buildLegendBadge('Skipped', '${breakdown.skipped}',
                  _AppColors.skipped, secondaryTextColor, textColor),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCORE TREND
  // ============================================================
  Widget _buildScoreTrend(bool isDark) {
    final cardColor = isDark ? const Color(0xFF16172B) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF64748B);

    final trends = _analyticsData!.scoreTrend;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Score Trend', textColor),
          const SizedBox(height: 18),
          if (trends.isEmpty)
            SizedBox(
              height: 90,
              child: Center(
                child: Text(
                  'No score trend data available',
                  style: TextStyle(color: secondaryTextColor, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 124,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: trends.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final trend = trends[index];
                  final Color barColor = trend.percentage >= 70
                      ? _AppColors.success
                      : trend.percentage >= 40
                      ? _AppColors.warning
                      : _AppColors.danger;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${trend.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryTextColor),
                      ),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 500 + index * 60),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, _) {
                          final h =
                              (trend.percentage.clamp(0, 100) / 100) * 62 + 6;
                          return Container(
                            height: h * t,
                            width: 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  barColor,
                                  barColor.withOpacity(0.6)
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                  bottom: Radius.circular(3)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${trend.date.day}/${trend.date.month}',
                        style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF94A3B8)),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // INSIGHTS
  // ============================================================
  Widget _buildInsights(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Insights', textColor),
        const SizedBox(height: 10),
        ..._analyticsData!.insights.map((insight) {
          final isWarning = insight.type == 'warning';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isWarning
                  ? (isDark
                  ? const Color(0xFF2D1F0A)
                  : const Color(0xFFFFFBEB))
                  : (isDark
                  ? const Color(0xFF0A1A2E)
                  : const Color(0xFFEFF6FF)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWarning
                    ? (isDark
                    ? const Color(0xFF8D6E1A)
                    : const Color(0xFFFDE68A))
                    : (isDark
                    ? const Color(0xFF1A3A6E)
                    : const Color(0xFFBFDBFE)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isWarning
                      ? Icons.warning_amber_rounded
                      : Icons.lightbulb_outline_rounded,
                  color: isWarning
                      ? (isDark
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD97706))
                      : (isDark
                      ? const Color(0xFF60A5FA)
                      : _AppColors.primary),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isWarning
                              ? (isDark
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF92400E))
                              : (isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF1E40AF)),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        insight.message,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color:
                          isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ============================================================
  // CATEGORY PERFORMANCE
  // ============================================================
  Widget _buildCategoryPerformance(bool isDark) {
    final cardColor = isDark ? const Color(0xFF16172B) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Category Performance', textColor),
          const SizedBox(height: 16),
          ..._analyticsData!.byCategory.map((cat) {
            final double progress = cat.totalMaxScore > 0
                ? (cat.totalScore / cat.totalMaxScore).clamp(0.0, 1.0)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cat.label,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${cat.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, _) => LinearProgressIndicator(
                        value: val,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          cat.percentage >= 50
                              ? _AppColors.success
                              : _AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // RETAKE PROGRESS
  // ============================================================
  Widget _buildRetakeProgress(bool isDark) {
    final cardColor = isDark ? const Color(0xFF16172B) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Retake Progress', textColor),
          const SizedBox(height: 14),
          ..._analyticsData!.retakeProgress.map((retake) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF101020)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  retake.testTitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                        'First: ${retake.firstPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor)),
                    Icon(Icons.arrow_right_alt_rounded,
                        size: 16,
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFF94A3B8)),
                    Text(
                      'Latest: ${retake.latestPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                        isDark ? Colors.white : _AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: retake.improved
                            ? (isDark
                            ? const Color(0xFF1A3A1A)
                            : const Color(0xFFDCFCE7))
                            : (isDark
                            ? const Color(0xFF3A1A1A)
                            : const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${retake.improved ? '+' : ''}${retake.improvement.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: retake.improved
                              ? (isDark
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF166534))
                              : (isDark
                              ? const Color(0xFFEF5350)
                              : const Color(0xFF991B1B)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT ATTEMPTS
  // ============================================================
  Widget _buildRecentAttempts(bool isDark) {
    final cardColor = isDark ? const Color(0xFF16172B) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF64748B);

    final attempts = _analyticsData!.recentAttempts.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Recent Attempts', textColor),
          const SizedBox(height: 14),
          ...attempts.map((attempt) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF101020)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: attempt.percentage >= 50
                      ? (isDark
                      ? const Color(0xFF1A3A1A)
                      : const Color(0xFFDCFCE7))
                      : (isDark
                      ? const Color(0xFF3A1A1A)
                      : const Color(0xFFFEE2E2)),
                  child: Text(
                    '${attempt.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: attempt.percentage >= 50
                          ? (isDark
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF15803D))
                          : (isDark
                          ? const Color(0xFFEF5350)
                          : const Color(0xFFB91C1C)),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attempt.test.title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        attempt.series.title,
                        style: TextStyle(
                            fontSize: 11, color: secondaryTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(attempt.submittedAt),
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white38
                          : const Color(0xFF94A3B8)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ============================================================
  // SERIES PERFORMANCE
  // ============================================================
  Widget _buildSeriesPerformance(bool isDark) {
    final cardColor = isDark ? const Color(0xFF16172B) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark, cardColor, borderColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Series Performance', textColor),
          const SizedBox(height: 14),
          ..._analyticsData!.bySeries.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 11.0),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF101020)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.library_books_outlined,
                    size: 18,
                    color: isDark
                        ? Colors.white38
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.seriesTitle,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('${item.attemptsCount} Attempts',
                          style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor)),
                    ],
                  ),
                ),
                Text(
                  '${item.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ============================================================
  // SKELETON LOADER
  // ============================================================
  Widget _buildSkeletonLoader({required Key key, required bool isDark}) {
    return _ShimmerSkeleton(key: key, isDark: isDark);
  }

  // ============================================================
  // EMPTY & ERROR
  // ============================================================
  Widget _buildEmptyState(bool isDark) {
    final secondaryTextColor =
    isDark ? Colors.white70 : Colors.grey.shade700;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 48,
              color:
              isDark ? Colors.white.withOpacity(0.4) : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No Analytics Data Available',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Attempt a test to see your progress here.',
            style: TextStyle(
              fontSize: 12.5,
              color: secondaryTextColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final errorTextColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D1B1B)
                    : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: isDark ? const Color(0xFFEF5350) : _AppColors.danger,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Failed to load analytics',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5, color: errorTextColor, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAnalytics,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isDark ? Colors.white : _AppColors.primary,
                foregroundColor:
                isDark ? const Color(0xFF0A0A0F) : Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Widget _sectionTitle(String title, Color textColor,
      {String? trailing, Color? trailingColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
            color: textColor,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: trailingColor,
            ),
          ),
      ],
    );
  }

  Widget _buildLegendBadge(String label, String value, Color color,
      Color secondaryTextColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(fontSize: 12, color: secondaryTextColor)),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  BoxDecoration _cardDecoration(
      bool isDark, Color cardColor, Color borderColor) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.25)
              : const Color(0x08000000),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ============================================================
// SHIMMER SKELETON
// ============================================================
class _ShimmerSkeleton extends StatefulWidget {
  final bool isDark;
  const _ShimmerSkeleton({super.key, required this.isDark});

  @override
  State<_ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<_ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _block(
      {double width = double.infinity,
        double height = 16,
        double radius = 8}) {
    final baseColor =
    widget.isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE9EDF5);
    final highlight =
    widget.isDark ? const Color(0xFF262640) : const Color(0xFFF6F8FC);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              begin: Alignment(-1.5 + t * 3, 0),
              end: Alignment(-0.5 + t * 3, 0),
              colors: [baseColor, highlight, baseColor],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('loading'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _block(width: 44, height: 44, radius: 12),
              const Spacer(),
              _block(width: 44, height: 44, radius: 12),
              const SizedBox(width: 10),
              _block(width: 44, height: 44, radius: 12),
              const SizedBox(width: 10),
              _block(width: 44, height: 44, radius: 13),
            ],
          ),
          const SizedBox(height: 26),
          Center(child: _block(width: 106, height: 106, radius: 53)),
          const SizedBox(height: 16),
          Center(child: _block(width: 140, height: 20)),
          const SizedBox(height: 10),
          Center(child: _block(width: 90, height: 14)),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              4,
                  (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 6, right: i == 3 ? 0 : 6),
                  child: _block(height: 96, radius: 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _block(height: 130, radius: 20),
          const SizedBox(height: 20),
          _block(height: 180, radius: 18),
          const SizedBox(height: 18),
          _block(height: 160, radius: 18),
        ],
      ),
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================
class _StatData {
  final String label;
  final int value;
  final String suffix;
  final IconData icon;
  final Color color;

  _StatData({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
  });
}

class _ActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgLight;
  final Color bgDark;

  _ActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgLight,
    required this.bgDark,
  });
}