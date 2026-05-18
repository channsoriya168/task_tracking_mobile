// ── Task Shimmer Skeleton ─────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

// ── Single task card skeleton ─────────────────────────────────
class TaskShimmerWidget extends StatelessWidget {
  const TaskShimmerWidget({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE8E8EE);
    final highlight = isDark
        ? const Color(0xFF3A3A4E)
        : const Color(0xFFF5F5FA);
    final cardBg = isDark ? kCardDark : Colors.white;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(18),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent strip
                Container(width: 4, color: base),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1 — title
                        Row(
                          children: [
                            Expanded(
                              child: _Box(
                                w: double.infinity,
                                h: 14,
                                r: 6,
                                color: base,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _Box(w: 22, h: 22, r: 6, color: base),
                          ],
                        ),
                        const SizedBox(height: 7),

                        // Row 2 — description
                        _Box(w: 200, h: 11, r: 5, color: base),
                        const SizedBox(height: 10),

                        // Row 3 — date range
                        Row(
                          children: [
                            _Box(w: 12, h: 12, r: 3, color: base),
                            const SizedBox(width: 5),
                            _Box(w: 70, h: 11, r: 5, color: base),
                            const SizedBox(width: 10),
                            _Box(w: 14, h: 11, r: 3, color: base),
                            const SizedBox(width: 5),
                            _Box(w: 70, h: 11, r: 5, color: base),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Row 4 — badges + avatar
                        Row(
                          children: [
                            _Box(w: 60, h: 20, r: 6, color: base),
                            const SizedBox(width: 8),
                            _Box(w: 8, h: 8, r: 4, color: base),
                            const SizedBox(width: 5),
                            _Box(w: 45, h: 11, r: 5, color: base),
                            const SizedBox(width: 8),
                            _Box(w: 55, h: 18, r: 20, color: base),
                            const Spacer(),
                            _Box(w: 20, h: 20, r: 10, color: base),
                            const SizedBox(width: 5),
                            _Box(w: 55, h: 11, r: 5, color: base),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shimmer list (6 skeletons) ────────────────────────────────
class ManagerTaskListShimmer extends StatelessWidget {
  const ManagerTaskListShimmer({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: kPageBottomPadding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: kItemSpacing,
        child: TaskShimmerWidget(isDark: isDark),
      ),
    );
  }
}

// ── Internal box helper ───────────────────────────────────────
class _Box extends StatelessWidget {
  const _Box({
    required this.w,
    required this.h,
    required this.r,
    required this.color,
  });

  final double w;
  final double h;
  final double r;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
