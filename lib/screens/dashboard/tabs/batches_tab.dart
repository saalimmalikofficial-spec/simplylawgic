// lib/screens/dashboard/tabs/batches_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class BatchesTab extends StatelessWidget {
  const BatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
    isDark ? const Color(0xFF0A0A0F) : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor =
    isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.06) : AppColors.border;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : AppColors.textPrimary.withOpacity(0.06);

    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          // 🔥 Decorative top gradient blob (light mode)
          if (!isDark)
            Positioned(
              top: -100,
              left: -50,
              right: -50,
              child: IgnorePointer(
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.0,
                      colors: [
                        AppColors.primary.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              // ============ ENROLLED SECTION ============
              _LedgerHeader(
                label: "Enrolled Files",
                icon: Icons.bookmark_added_rounded,
                iconColor: const Color(0xFF10B981),
                isDark: isDark,
                textColor: textColor,
                borderColor: borderColor,
              ),
              const SizedBox(height: 14),

              _EnrolledBatchFile(
                status: "ACTIVE",
                statusColor: const Color(0xFF10B981),
                title: "Judiciary Master Preparation Batch 2026",
                subtitle: "Live Classes • Major Laws • Daily Tests",
                expiryLabel: "VALID · 8 MONTHS LEFT",
                progress: 0.42,
                modulesCompleted: 18,
                totalModules: 42,
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                shadowColor: shadowColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                onTap: () =>
                    _toast(context, 'Redirecting to live class...', isDark),
              ),

              const SizedBox(height: 32),

              // ============ EXPLORE SECTION ============
              _LedgerHeader(
                label: "Explore New Batches",
                icon: Icons.explore_rounded,
                iconColor: AppColors.primary,
                isDark: isDark,
                textColor: textColor,
                borderColor: borderColor,
                trailing: TextButton(
                  onPressed: () =>
                      _toast(context, 'More batches coming soon!', isDark),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward,
                          size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _ExploreBatchFile(
                ribbonText: "POPULAR",
                ribbonColor: const Color(0xFFF97316),
                accentColor: const Color(0xFFF97316),
                icon: Icons.local_fire_department_rounded,
                title: "Comprehensive Law Foundation 2026",
                subtitle: "Covers Civil & Criminal Laws with Answer Writing",
                startDate: "Starts 15 Aug",
                duration: "12 Months",
                price: "₹14,999",
                originalPrice: "₹19,999",
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                shadowColor: shadowColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                onEnroll: () => _toast(
                    context,
                    'Enrolling in Comprehensive Law Foundation 2026...',
                    isDark),
              ),
              const SizedBox(height: 14),

              _ExploreBatchFile(
                ribbonText: "CRASH COURSE",
                ribbonColor: AppColors.primary,
                accentColor: AppColors.primary,
                icon: Icons.flash_on_rounded,
                title: "Minor Laws & Local Acts Crash Course",
                subtitle: "30-Day Intensive Revision for Judiciary Exams",
                startDate: "Starts 01 Sept",
                duration: "30 Days",
                price: "₹4,999",
                originalPrice: "₹7,999",
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                shadowColor: shadowColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                onEnroll: () => _toast(
                    context,
                    'Enrolling in Minor Laws & Local Acts Crash Course...',
                    isDark),
              ),

              const SizedBox(height: 14),

              // 🔥 3rd explore card (bonus)
              _ExploreBatchFile(
                ribbonText: "NEW",
                ribbonColor: const Color(0xFF8B5CF6),
                accentColor: const Color(0xFF8B5CF6),
                icon: Icons.auto_awesome_rounded,
                title: "Answer Writing Masterclass",
                subtitle: "Learn to score high with structured answers",
                startDate: "Starts 20 Sept",
                duration: "6 Weeks",
                price: "₹2,999",
                originalPrice: "₹4,499",
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                shadowColor: shadowColor,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                onEnroll: () => _toast(
                    context, 'Enrolling in Answer Writing Masterclass...', isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String msg, bool isDark) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================
class _LedgerHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final bool isDark;
  final Color textColor;
  final Color borderColor;

  const _LedgerHeader({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.trailing,
    required this.isDark,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
            color: textColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: borderColor),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

// ============================================================
// DASHED RULE
// ============================================================
class _DashedRule extends StatelessWidget {
  final Color color;
  const _DashedRule({this.color = const Color(0x00000000)});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
                (_) => Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: Container(width: dashWidth, height: 1, color: color),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// ENROLLED BATCH CARD
// ============================================================
class _EnrolledBatchFile extends StatelessWidget {
  final String status;
  final Color statusColor;
  final String title;
  final String subtitle;
  final String expiryLabel;
  final double progress;
  final int modulesCompleted;
  final int totalModules;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const _EnrolledBatchFile({
    required this.status,
    required this.statusColor,
    required this.title,
    required this.subtitle,
    required this.expiryLabel,
    required this.progress,
    required this.modulesCompleted,
    required this.totalModules,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ============ HEADER BAR ============
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColor,
                  statusColor.withOpacity(0.75),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 4),
                const Text(
                  "Enrolled",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ============ BODY ============
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Progress bar
                Row(
                  children: [
                    Text(
                      "Progress",
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "$modulesCompleted / $totalModules Modules",
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 12),

                _DashedRule(color: borderColor),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Transform.rotate(
                      angle: -0.03,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: statusColor.withOpacity(0.6),
                              width: 1.2),
                          color: statusColor.withOpacity(0.08),
                        ),
                        child: Text(
                          expiryLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                "Go to Class",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
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
        ],
      ),
    );
  }
}

// ============================================================
// EXPLORE BATCH CARD
// ============================================================
class _ExploreBatchFile extends StatelessWidget {
  final String ribbonText;
  final Color ribbonColor;
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String startDate;
  final String duration;
  final String price;
  final String originalPrice;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onEnroll;

  const _ExploreBatchFile({
    required this.ribbonText,
    required this.ribbonColor,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ============ TOP ACCENT STRIP ============
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.5)],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ribbon + icon row
                Row(
                  children: [
                    // Ribbon pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ribbonColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: ribbonColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            ribbonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Duration chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 11, color: secondaryTextColor),
                          const SizedBox(width: 3),
                          Text(
                            duration,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Start date row
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 13, color: accentColor),
                    const SizedBox(width: 5),
                    Text(
                      startDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                _DashedRule(color: borderColor),
                const SizedBox(height: 12),

                // Price + Enroll button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              originalPrice,
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onEnroll,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: accentColor, width: 1.5),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Enroll",
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 14, color: accentColor),
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
        ],
      ),
    );
  }
}