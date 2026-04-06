import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class TaskDetailRow extends StatelessWidget {
  const TaskDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.child,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(fontSize: 13, color: mutedColor)),
        ),
        Expanded(child: child),
      ],
    );
  }
}
