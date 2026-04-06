import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class LoginBgCircles extends StatelessWidget {
  const LoginBgCircles({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _Circle(
            size: 220,
            color: kPrimary.withValues(alpha: isDark ? 0.15 : 0.08),
          ),
        ),
        Positioned(
          top: 60,
          right: 40,
          child: _Circle(
            size: 80,
            color: kPrimary.withValues(alpha: isDark ? 0.2 : 0.12),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _Circle(
            size: 260,
            color: kPrimary.withValues(alpha: isDark ? 0.12 : 0.07),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 30,
          child: _Circle(
            size: 60,
            color: kPrimary.withValues(alpha: isDark ? 0.18 : 0.1),
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
