import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class GroupShimmerWidget extends StatefulWidget {
  const GroupShimmerWidget({super.key, required this.isDark});

  final bool isDark;

  @override
  State<GroupShimmerWidget> createState() => _GroupShimmerWidgetState();
}

class _GroupShimmerWidgetState extends State<GroupShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final base = widget.isDark
            ? Color.lerp(
                const Color(0xFF2A2A2A),
                const Color(0xFF3A3A3A),
                _anim.value,
              )!
            : Color.lerp(
                const Color(0xFFE8E8E8),
                const Color(0xFFF4F4F4),
                _anim.value,
              )!;
        final accent = widget.isDark
            ? Color.lerp(
                const Color(0xFF333333),
                const Color(0xFF444444),
                _anim.value,
              )!
            : Color.lerp(
                const Color(0xFFDDDDDD),
                const Color(0xFFEEEEEE),
                _anim.value,
              )!;

        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? kCardDark : kBgLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Left accent bar
                    Container(width: 5, height: 70, color: accent),
                    const SizedBox(width: 14),
                    // Icon avatar placeholder
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 120,
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
                                color: accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Menu icon placeholder
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: widget.isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 11,
                        width: 80,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
