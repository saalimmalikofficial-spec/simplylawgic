// lib/screens/dashboard/tabs/batches_tab.dart
import 'package:flutter/material.dart';
import 'package:simplylawgic/utils/app_colors.dart';

class BatchesTab extends StatelessWidget {
  const BatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // No nested Scaffold — this tab lives inside the dashboard's Scaffold
    // (bottom nav). Wrapping it again would cause background flashes /
    // double safe-area padding.
    return Container(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        children: [
          const _LedgerHeader(label: "Enrolled Files"),
          const SizedBox(height: 14),

          _EnrolledBatchFile(
            status: "ACTIVE",
            title: "Judiciary Master Preparation Batch 2026",
            subtitle: "Live Classes • Major Laws • Daily Tests",
            expiryLabel: "VALID · 8 MONTHS LEFT",
            onTap: () => _toast(context, 'Redirecting to live class...'),
          ),

          const SizedBox(height: 32),

          _LedgerHeader(
            label: "Explore New Batches",
            trailing: TextButton(
              onPressed: () => _toast(context, 'More batches coming soon!'),
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
            onEnroll: () => _toast(context, 'Enrolling in Comprehensive Law Foundation 2026...'),
          ),
          const SizedBox(height: 14),
          _ExploreBatchFile(
            ribbonText: "CRASH COURSE",
            ribbonColor: AppColors.primary,
            title: "Minor Laws & Local Acts Crash Course",
            subtitle: "30-Day Intensive Revision for Judiciary Exams",
            startDate: "Starts 01 Sept",
            price: "₹4,999",
            onEnroll: () => _toast(context, 'Enrolling in Minor Laws & Local Acts Crash Course...'),
          ),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Small "ledger" style section header — an eyebrow label with a hairline
/// rule, evoking a docket/file-index heading rather than a plain title.
class _LedgerHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _LedgerHeader({required this.label, this.trailing});

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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: AppColors.border),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

/// Thin dashed rule — used instead of a plain Divider to read like a
/// ruled line on a legal document.
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

/// The enrolled batch, styled as an open case file: a rotated tab strip
/// on the left carries the status, and the expiry reads like a stamped
/// docket entry.
class _EnrolledBatchFile extends StatelessWidget {
  final String status;
  final String title;
  final String subtitle;
  final String expiryLabel;
  final VoidCallback onTap;

  const _EnrolledBatchFile({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.expiryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folder tab strip — minHeight keeps it visible even if content
          // is short; it stretches automatically once content is taller.
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
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  _DashedRule(color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Rubber-stamp style expiry chip
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

/// An explore-batch card styled with a folded-corner ribbon badge instead
/// of a plain pill, and a dashed rule separating info from price/CTA.
class _ExploreBatchFile extends StatelessWidget {
  final String ribbonText;
  final Color ribbonColor;
  final String title;
  final String subtitle;
  final String startDate;
  final String price;
  final VoidCallback onEnroll;

  const _ExploreBatchFile({
    required this.ribbonText,
    required this.ribbonColor,
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.price,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
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
                    const SizedBox(width: 84), // keep clear of the ribbon
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      startDate,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                _DashedRule(color: AppColors.border),
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
          // Folded-corner ribbon badge — fixed size + FittedBox so any
          // label length ("POPULAR" or "CRASH COURSE") scales to fit
          // instead of clipping against the card's rounded corner.
          Positioned(
            top: 14,
            left: -30,
            child: Transform.rotate(
              angle: -0.7853981634, // -45deg
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