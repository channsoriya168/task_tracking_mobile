import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 52,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white38 : kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
