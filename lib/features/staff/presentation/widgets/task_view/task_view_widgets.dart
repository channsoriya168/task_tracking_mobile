import 'package:flutter/material.dart';

// ── Shared card container ────────────────────────────────────────

class TaskViewSectionCard extends StatelessWidget {
  const TaskViewSectionCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.cardBg,
  });

  final Widget child;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

// ── Shared section header ────────────────────────────────────────

class TaskViewSectionHeader extends StatelessWidget {
  const TaskViewSectionHeader({
    super.key,
    required this.label,
    required this.isDark,
  });

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: isDark ? Colors.white70 : const Color(0xFF374151),
      ),
    );
  }
}
