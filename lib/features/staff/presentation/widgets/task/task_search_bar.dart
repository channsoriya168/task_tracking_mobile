import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class TaskSearchBar extends StatelessWidget {
  const TaskSearchBar({super.key, required this.ctrl, required this.isDark});

  final TaskController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPageSectionPadding,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (v) => ctrl.searchQuery.value = v,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : kTextDark,
          ),
          decoration: const InputDecoration(
            hintText: 'Search tasks...',
            hintStyle: TextStyle(color: kTextMuted, fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: kTextMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
