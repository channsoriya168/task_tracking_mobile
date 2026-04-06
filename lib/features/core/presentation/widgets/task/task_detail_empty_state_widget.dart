import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class TaskDetailEmptyState extends StatelessWidget {
  const TaskDetailEmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.isDark,
  });

  final IconData icon;
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white24 : kTextMuted;
    return SizedBox(
      height: 80,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: mutedColor),
            const SizedBox(height: 6),
            Text(message, style: TextStyle(fontSize: 12, color: mutedColor)),
          ],
        ),
      ),
    );
  }
}
