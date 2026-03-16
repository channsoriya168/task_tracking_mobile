import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_detail_sheet.dart';

class EmployeeTaskCard extends StatelessWidget {
  const EmployeeTaskCard({
    super.key,
    required this.task,
    required this.isDark,
  });

  final TaskItem task;
  final bool isDark;

  Future<void> _onAccept(BuildContext context) async {
    final label = task.labelName ?? task.groupName;
    final title = label != null ? '${task.title} ($label)' : task.title;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? kCardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Accept Task',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
        content: Text(
          'Are you sure you want to accept\n"$title"?',
          style: TextStyle(
            color: isDark ? Colors.white70 : kTextMuted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No',
              style: TextStyle(color: isDark ? Colors.white54 : kTextMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ctrl = Get.find<EmployeeTaskController>();
      final success = await ctrl.acceptTask(task);
      if (success) {
        Get.snackbar(
          'Task Accepted',
          'You have accepted the task successfully.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Failed',
          ctrl.errorMessage.value.isNotEmpty
              ? ctrl.errorMessage.value
              : 'Could not accept task. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? kCardDark : Colors.white;
    final mutedColor = isDark ? Colors.white54 : kTextMuted;
    final statusColor = task.status.color;
    final priorityColor = task.priority.color;

    return GestureDetector(
      onTap: () => showEmployeeTaskDetailSheet(context, isDark, task),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left accent strip ──────────────────────────
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor,
                        statusColor.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                ),
                // ── Content ────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1 — title (label)
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: task.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : kTextDark,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              if ((task.labelName ?? task.groupName) != null)
                                TextSpan(
                                  text:
                                      '  (${task.labelName ?? task.groupName})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: mutedColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Row 2 — description
                        if ((task.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Row 3 — start date → due date
                        Row(
                          children: [
                            Icon(
                              Icons.today_rounded,
                              size: 11,
                              color: mutedColor,
                            ),
                            const SizedBox(width: 4),
                            if (task.startDate != null)
                              Text(
                                formatDate(task.startDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
                                ),
                              ),
                            if (task.startDate == null &&
                                task.createdAt != null)
                              Text(
                                formatDate(task.createdAt!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            if (task.dueDate != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Icon(
                                  Icons.arrow_right_alt_rounded,
                                  size: 13,
                                  color: mutedColor,
                                ),
                              ),
                              Text(
                                formatDate(task.dueDate!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Row 4 — status · priority · accept button
                        Row(
                          children: [
                            StatusBadgeWidget(
                              label: task.status.name,
                              color: statusColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.priority.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            // Accept button — only show when not already assigned
                            if (task.assignedToName == null)
                              GestureDetector(
                                onTap: () => _onAccept(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: kPrimary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Text(
                                    'Accept',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
