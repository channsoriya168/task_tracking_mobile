import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';

class TaskDetailAvatarName extends StatelessWidget {
  const TaskDetailAvatarName({
    super.key,
    required this.name,
    required this.color,
    required this.textColor,
  });

  final String name;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(name, style: AppTextStyles.formLabel(color: textColor)),
        ),
      ],
    );
  }
}
