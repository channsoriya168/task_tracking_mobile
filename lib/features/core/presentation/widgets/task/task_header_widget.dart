import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_controller.dart';

class TaskHeaderWidget extends StatelessWidget {
  const TaskHeaderWidget({super.key, required this.isDark, required this.ctrl});

  final bool isDark;
  final TaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPagePaddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
        ],
      ),
    );
  }
}
