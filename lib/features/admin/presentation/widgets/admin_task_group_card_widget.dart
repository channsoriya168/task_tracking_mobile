import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/action_button.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_group_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_task_group_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';

class AdminTaskGroupCardWidget extends StatelessWidget {
  const AdminTaskGroupCardWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
    required this.taskGroup,
  });

  final bool isDark;
  final AdminTaskGroupController ctrl;
  final TaskGroup taskGroup;

  @override
  Widget build(BuildContext context) {
    final color = taskGroup.color ?? kPrimary;
    return Dismissible(
      key: ValueKey(taskGroup.id),
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
      onDismissed: (_) => ctrl.deleteTaskGroup(taskGroup.id),
      child: GestureDetector(
        onTap: () => showAdminTaskGroupDialog(context, ctrl, isDark, taskGroup),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withAlpha(100),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 40 : 10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Color dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskGroup.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                    if (taskGroup.description != null &&
                        taskGroup.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        taskGroup.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ActionButton(
                icon: Icons.edit_rounded,
                color: kMediumPriority,
                onTap: () =>
                    showAdminTaskGroupDialog(context, ctrl, isDark, taskGroup),
              ),
              const SizedBox(width: 6),
              ActionButton(
                icon: Icons.delete_rounded,
                color: kHighPriority,
                onTap: () async {
                  final confirmed = await _confirmDelete(context);
                  if (confirmed == true) ctrl.deleteTaskGroup(taskGroup.id);
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
      title: 'Delete Task Group',
      content: 'Delete task group "${taskGroup.name}"?',
    );
  }
}
