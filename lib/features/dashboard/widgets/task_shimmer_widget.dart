// ── Shimmer card placeholder ───────────────────────────────────────────────
import 'package:flutter/material.dart';

class TaskShimmerWidget extends StatefulWidget {
  const TaskShimmerWidget({
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });
  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  @override
  State<TaskShimmerWidget> createState() => _TaskShimmerState();
}

class _TaskShimmerState extends State<TaskShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    final base = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    final highlight = widget.isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.10);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Color.lerp(base, highlight, _anim.value)!;
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.borderColor),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 13,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 11,
                width: 160,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
