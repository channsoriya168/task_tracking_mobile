import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class DashboardShimmerWidget extends StatelessWidget {
  const DashboardShimmerWidget({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF252540) : Colors.grey.shade300;
    final highlight = isDark ? const Color(0xFF3A3A60) : Colors.grey.shade100;
    final cardBg = isDark ? kCardDark : Colors.white;
    final shimmerColor = isDark ? Colors.white24 : Colors.grey.shade400;
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    );

    Widget box(double w, double h, {double r = 6}) => Container(
          width: w == double.infinity ? null : w,
          height: h,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(r),
          ),
        );

    Widget taskCard() => Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [shadow],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: box(double.infinity, 16)),
                            const SizedBox(width: 8),
                            box(10, 10, r: 5),
                          ],
                        ),
                        const SizedBox(height: 8),
                        box(double.infinity, 12),
                        const SizedBox(height: 5),
                        box(180, 12),
                        const SizedBox(height: 10),
                        box(100, 12),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            box(28, 28, r: 14),
                            const Spacer(),
                            box(90, 32, r: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chart Card ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [shadow],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(150, 16),
                  const SizedBox(height: 8),
                  box(110, 12),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Donut placeholder
                      box(140, 140, r: 70),
                      const SizedBox(width: 14),
                      // Legend rows
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            7,
                            (_) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  box(10, 10, r: 5),
                                  const SizedBox(width: 8),
                                  box(58, 11),
                                  const Spacer(),
                                  box(44, 11),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Task Count Row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                box(52, 16),
                const SizedBox(width: 8),
                box(28, 20, r: 10),
              ],
            ),
          ),

          // ── Task Card Skeletons ───────────────────────────────────
          ...List.generate(
            5,
            (_) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: taskCard(),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}