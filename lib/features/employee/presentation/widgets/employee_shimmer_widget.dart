// ── Employee Shimmer Skeletons ────────────────────────────────
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

// ── List card skeleton ─────────────────────────────────────────
class EmployeeCardShimmer extends StatelessWidget {
  const EmployeeCardShimmer({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE8E8EE);
    final highlight = isDark ? const Color(0xFF3A3A4E) : const Color(0xFFF5F5FA);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: base, shape: BoxShape.circle),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBox(width: 130, height: 13, color: base),
                  const SizedBox(height: 7),
                  _ShimmerBox(width: 100, height: 11, color: base),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 70, height: 16, color: base, radius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grid card skeleton ─────────────────────────────────────────
class EmployeeGridCardShimmer extends StatelessWidget {
  const EmployeeGridCardShimmer({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE8E8EE);
    final highlight = isDark ? const Color(0xFF3A3A4E) : const Color(0xFFF5F5FA);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: base, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBox(width: double.infinity, height: 12, color: base),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 55, height: 15, color: base, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer list (6 skeleton cards) ───────────────────────────
class EmployeeListShimmer extends StatelessWidget {
  const EmployeeListShimmer({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => EmployeeCardShimmer(isDark: isDark),
    );
  }
}

// ── Shimmer grid (6 skeleton cards) ───────────────────────────
class EmployeeGridShimmer extends StatelessWidget {
  const EmployeeGridShimmer({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 88,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => EmployeeGridCardShimmer(isDark: isDark),
    );
  }
}

// ── Internal helper ────────────────────────────────────────────
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 6,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}