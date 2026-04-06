import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class TaskCardShimmerWidget extends StatelessWidget {
  const TaskCardShimmerWidget({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlight = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: base,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      width: 180,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 60,
                          decoration: BoxDecoration(
                            color: base,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 7,
                          width: 7,
                          decoration: BoxDecoration(
                            color: base,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 11,
                          width: 50,
                          decoration: BoxDecoration(
                            color: base,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: base,
                            shape: BoxShape.circle,
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
      ),
    );
  }
}
