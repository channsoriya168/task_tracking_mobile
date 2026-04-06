import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_empty_state_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_tab_loader_widget.dart';

class TaskDetailMembersTab extends StatelessWidget {
  const TaskDetailMembersTab({
    super.key,
    required this.members,
    required this.loading,
    required this.isDark,
  });

  final List<TaskMember> members;
  final bool loading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (loading) return const TaskDetailTabLoader();
    if (members.isEmpty) {
      return TaskDetailEmptyState(
        icon: Icons.group_off_outlined,
        message: 'No members assigned',
        isDark: isDark,
      );
    }

    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (int i = 0; i < members.length; i++) ...[
            if (i > 0) Divider(height: 1, color: divColor),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  TaskDetailAvatar(
                    name: members[i].employeeName,
                    imageUrl: members[i].employeeProfileImageUrl,
                    size: 34,
                    color: kPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          members[i].employeeName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (members[i].addedByName != null)
                          Text(
                            'Added by ${members[i].addedByName}',
                            style: TextStyle(fontSize: 11, color: mutedColor),
                          ),
                      ],
                    ),
                  ),
                  if (members[i].assignedAt != null)
                    Text(
                      formatDate(members[i].assignedAt!),
                      style: TextStyle(fontSize: 10, color: mutedColor),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
