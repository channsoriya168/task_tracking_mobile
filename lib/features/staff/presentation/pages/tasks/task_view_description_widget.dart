import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'task_view_widgets.dart';

class TaskViewDescriptionSection extends StatelessWidget {
  const TaskViewDescriptionSection({
    super.key,
    required this.description,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });

  final String description;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return TaskViewSectionCard(
      borderColor: borderColor,
      cardBg: cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskViewSectionHeader(label: 'Description', isDark: isDark),
          const SizedBox(height: 10),
          description.trim().isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No description was provided for this task.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark ? Colors.white30 : kTextMuted,
                    ),
                  ),
                )
              : Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark
                        ? Colors.white70
                        : const Color(0xFF374151),
                  ),
                ),
        ],
      ),
    );
  }
}
