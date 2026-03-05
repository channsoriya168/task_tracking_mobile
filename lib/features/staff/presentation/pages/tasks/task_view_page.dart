import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

part 'task_view_widgets.dart';

class TaskViewPage extends StatelessWidget {
  final TaskModel task;

  const TaskViewPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE5E7EB);
    final cardBg = isDark ? kCardDark : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      appBar: _buildAppBar(isDark, borderColor, cardBg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ViewHeaderCard(
                task: task, isDark: isDark,
                borderColor: borderColor, cardBg: cardBg),
            const SizedBox(height: 16),
            _ViewDescriptionSection(
                description: task.description,
                isDark: isDark, borderColor: borderColor, cardBg: cardBg),
            const SizedBox(height: 12),
            _ViewMembersSection(
                members: task.members,
                isDark: isDark, borderColor: borderColor, cardBg: cardBg),
            const SizedBox(height: 12),
            _ViewProgressSection(
                items: task.progressItems,
                isDark: isDark, borderColor: borderColor, cardBg: cardBg),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark, Color borderColor, Color cardBg) {
    return AppBar(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: Get.back,
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: isDark ? Colors.white : kTextDark),
        ),
      ),
      leadingWidth: 60,
      title: Text(
        'Task Overview',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : kTextMuted,
        ),
      ),
    );
  }
}
