import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';

Future<void> showTaskDetailSheet(
  BuildContext context,
  bool isDark,
  TaskItem task,
  ManagerTaskController controller,
) async {
  final posCtrl = Get.find<TaskGroupController>();
  final taskGroup = task.groupId != null
      ? posCtrl.findPosition(task.groupId!)
      : null;
  final positionColor = taskGroup?.color ?? kPrimary;
  final textColor = isDark ? Colors.white : kTextDark;
  final mutedColor = isDark ? Colors.white38 : kTextMuted;
  final divColor = isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              task.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.3,
              ),
            ),

            // Description
            if ((task.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                task.description!,
                style: TextStyle(fontSize: 14, color: mutedColor, height: 1.6),
              ),
            ],

            const SizedBox(height: 20),
            Divider(height: 1, color: divColor),
            const SizedBox(height: 20),

            // Position / Group
            _DetailRow(
              icon: Icons.work_outline_rounded,
              label: 'Position',
              isDark: isDark,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: positionColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: positionColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  task.groupName ?? task.labelName ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: positionColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Due date
            if (task.dueDate != null) ...[
              _DetailRow(
                icon: Icons.event_rounded,
                label: 'Due Date',
                isDark: isDark,
                child: Text(
                  formatDate(task.dueDate!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Accepted by
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Accepted by',
              isDark: isDark,
              child: task.assignedToName != null
                  ? Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(
                              alpha: isDark ? 0.25 : 0.12,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            task.assignedToName![0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.assignedToName!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Not accepted yet',
                      style: TextStyle(fontSize: 14, color: mutedColor),
                    ),
            ),
            const SizedBox(height: 16),

            // Created at
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: 'Created',
              isDark: isDark,
              child: Text(
                formatDate(task.createdAt ?? DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.child,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(fontSize: 13, color: mutedColor)),
        ),
        Expanded(child: child),
      ],
    );
  }
}

