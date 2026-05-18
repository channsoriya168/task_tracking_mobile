import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class TaskCardShimmer extends StatelessWidget {
  const TaskCardShimmer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF252540) : Colors.grey.shade300;
    final highlight = isDark ? const Color(0xFF3A3A60) : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent strip ──
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // ── Content ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title + priority dot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ShimmerBox(
                              isDark: isDark,
                              width: double.infinity,
                              height: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ShimmerBox(
                            isDark: isDark,
                            width: 10,
                            height: 10,
                            radius: 5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description line 1
                      _ShimmerBox(
                        isDark: isDark,
                        width: double.infinity,
                        height: 12,
                      ),
                      const SizedBox(height: 5),
                      // Description line 2
                      _ShimmerBox(isDark: isDark, width: 180, height: 12),
                      const SizedBox(height: 10),
                      // Due date
                      _ShimmerBox(isDark: isDark, width: 100, height: 12),
                      const SizedBox(height: 14),
                      // Avatar + action button
                      Row(
                        children: [
                          _ShimmerBox(
                            isDark: isDark,
                            width: 28,
                            height: 28,
                            radius: 14,
                          ),
                          const Spacer(),
                          _ShimmerBox(
                            isDark: isDark,
                            width: 90,
                            height: 32,
                            radius: 10,
                          ),
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
    );
  }
}
// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.isDark,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final bool isDark;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
