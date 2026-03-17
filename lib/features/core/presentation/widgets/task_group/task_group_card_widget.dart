// ── Position Card ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/action_button.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_group/task_group_dialog.dart';

class TaskGroupCardWidget extends StatelessWidget {
  const TaskGroupCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.position,
    required this.employeeCount,
  });

  final bool isDark;
  final TaskGroupController ctrl;
  final TaskGroup position;
  final int employeeCount;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(position.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ctrl.deleteTaskGroup(position.id),
      child: GestureDetector(
        onTap: () => showTaskGroupDialog(context, ctrl, isDark, position),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? kBgDark : kBgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (position.color ?? kPrimary).withAlpha(100),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$employeeCount ${employeeCount == 1 ? 'member' : 'members'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              ActionButton(
                icon: Icons.edit_rounded,
                color: position.color ?? kPrimary,
                onTap: () =>
                    showTaskGroupDialog(context, ctrl, isDark, position),
              ),
              const SizedBox(width: 6),
              ActionButton(
                icon: Icons.delete_rounded,
                color: kHighPriority,
                onTap: () async {
                  final confirmed = await _confirmDelete(context);
                  if (confirmed == true) ctrl.deleteTaskGroup(position.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showConfirmDeleteDialog(
      context,
      title: 'Delete Position',
      content: employeeCount > 0
          ? 'This will also remove $employeeCount ${employeeCount == 1 ? 'employee' : 'employees'} in "${position.name}". Continue?'
          : 'Delete position "${position.name}"?',
    );
  }
}
