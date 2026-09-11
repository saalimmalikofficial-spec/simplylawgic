// lib/screens/dashboard/tabs/batches_tab.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class BatchesTab extends StatelessWidget {
  const BatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0A0A0F) : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : AppColors.border;
    final shadowColor = isDark ? Colors.white.withOpacity(0.03) : AppColors.textPrimary.withOpacity(0.05);

    return Container(
      color: backgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        children: [
          _LedgerHeader(
            label: "Enrolled Files",
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 14),

          _EnrolledBatchFile(
            status: "ACTIVE",
            title: "Judiciary Master Preparation Batch 2026",
            subtitle: "Live Classes • Major Laws • Daily Tests",
            expiryLabel: "VALID · 8 MONTHS LEFT",
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            shadowColor: shadowColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onTap: () => _toast(context, 'Redirecting to live class...', isDark),
          ),

          const SizedBox(height: 32),

          _LedgerHeader(
            label: "Explore New Batches",
            isDark: isDark,
            textColor: textColor,
            trailing: TextButton(
              onPressed: () => _toast(context, 'More batches coming soon!', isDark),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
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
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          _ExploreBatchFile(
            ribbonText: "POPULAR",
            ribbonColor: Colors.orange.shade700,
            title: "Comprehensive Law Foundation 2026",
            subtitle: "Covers Civil & Criminal Laws with Answer Writing",
            startDate: "Starts 15 Aug",
            price: "₹14,999",
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            shadowColor: shadowColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onEnroll: () => _toast(context, 'Enrolling in Comprehensive Law Foundation 2026...', isDark),
          ),
          const SizedBox(height: 14),
          _ExploreBatchFile(
            ribbonText: "CRASH COURSE",
            ribbonColor: AppColors.primary,
            title: "Minor Laws & Local Acts Crash Course",
            subtitle: "30-Day Intensive Revision for Judiciary Exams",
            startDate: "Starts 01 Sept",
            price: "₹4,999",
            isDark: isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            shadowColor: shadowColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            onEnroll: () => _toast(context, 'Enrolling in Minor Laws & Local Acts Crash Course...', isDark),
          ),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String msg, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      ),
    );
  }
}

class _LedgerHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final bool isDark;
  final Color textColor;

  const _LedgerHeader({
    required this.label,
    this.trailing,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: textColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: isDark ? Colors.white.withOpacity(0.06) : AppColors.border,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

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
              child: Container(
                width: dashWidth,
                height: 1,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnrolledBatchFile extends StatelessWidget {
  final String status;
  final String title;
  final String subtitle;
  final String expiryLabel;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const _EnrolledBatchFile({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.expiryLabel,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            constraints: const BoxConstraints(minHeight: 130),
            color: Colors.green.shade600,
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 16, 14),
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
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DashedRule(color: borderColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Transform.rotate(
                        angle: -0.035,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade600, width: 1.2),
                          ),
                          child: Text(
                            expiryLabel,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_circle_fill, color: Colors.white, size: 15),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreBatchFile extends StatelessWidget {
  final String ribbonText;
  final Color ribbonColor;
  final String title;
  final String subtitle;
  final String startDate;
  final String price;
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
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.price,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 84),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      startDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 14),
                _DashedRule(color: borderColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    InkWell(
                      onTap: onEnroll,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary, width: 1.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Enroll",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 13, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 14,
            left: -30,
            child: Transform.rotate(
              angle: -0.7853981634,
              child: Container(
                width: 110,
                height: 22,
                alignment: Alignment.center,
                color: ribbonColor,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ribbonText,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}