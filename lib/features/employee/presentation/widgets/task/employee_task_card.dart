import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_card_date_row.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_card_footer_row.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_card_title_row.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_detail_sheet.dart';

class EmployeeTaskCard extends StatelessWidget {
  const EmployeeTaskCard({
    super.key,
    required this.task,
    required this.isDark,

    /// Direct accept callback (used by home page for confirm-dialog flow).
    this.onAccept,
  });

  final TaskItem task;
  final bool isDark;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white54 : kTextMuted;
    final statusColor = task.status.color;
    final ctrl = Get.find<EmployeeTaskController>();
    final currentId = ctrl.currentEmployeeId;

    final isPending = task.assignedToId == null;
    final isMyTask =
        task.assignedToId != null && task.assignedToId == currentId;
    final isAssignedToOther = task.assignedToId != null && !isMyTask;

    void openDetail({bool readOnly = false}) {
      ctrl.prepareTaskDetail(task.id);
      showEmployeeTaskDetailSheet(context, isDark, task, readOnly: readOnly);
    }

    final startLabel = task.startDate != null
        ? formatDate(task.startDate!)
        : (task.createdAt != null ? formatDate(task.createdAt!) : '');

    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);

    // Available transitions from the API.
    final transitions =
        isMyTask ? task.allowedTransitions : <TaskStatusLookup>[];
    final primaryTransition =
        transitions.isNotEmpty ? transitions.first : null;

    return GestureDetector(
      // Pending/my tasks → interactive detail; others' tasks → read-only
      onTap: () => openDetail(readOnly: isAssignedToOther),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPending
                ? kPrimary.withValues(alpha: 0.35)
                : isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.07),
            width: isPending ? 1.5 : 1,
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
                // ── Left accent strip ──
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [statusColor, statusColor.withValues(alpha: 0.4)],
                    ),
                  ),
                ),
                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main info area
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TaskCardTitleRow(
                              task: task,
                              isDark: isDark,
                              mutedColor: mutedColor,
                            ),
                            const SizedBox(height: 8),
                            TaskCardDateRow(
                              mutedColor: mutedColor,
                              startLabel: startLabel,
                              isStartFallback: task.startDate == null,
                              dueDate: task.dueDate,
                            ),
                            const SizedBox(height: 8),
                            TaskCardFooterRow(
                              task: task,
                              isDark: isDark,
                              mutedColor: mutedColor,
                              statusColor: statusColor,
                              priorityColor: task.priority.color,
                            ),
                          ],
                        ),
                      ),

                      // ── Action area (varies by task state) ──
                      if (isPending)
                        // Unassigned — anyone in the group can accept
                        _AcceptBar(
                          isDark: isDark,
                          dividerColor: dividerColor,
                          onTap: onAccept ?? () => openDetail(),
                        )
                      else if (isAssignedToOther)
                        // Already taken by someone else — read-only indicator
                        _TakenBar(
                          name: task.assignedToName ?? 'someone',
                          isDark: isDark,
                          dividerColor: dividerColor,
                        )
                      else if (primaryTransition != null)
                        _StatusActionBar(
                          label: 'Update Status',
                          color: primaryTransition.color,
                          isDark: isDark,
                          dividerColor: dividerColor,
                          onTap: () => openDetail(),
                        ),
                    ],
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

// ── Accept bar: prominent, full-width — for unassigned group tasks ─────────────

class _AcceptBar extends StatelessWidget {
  const _AcceptBar({
    required this.isDark,
    required this.dividerColor,
    required this.onTap,
  });

  final bool isDark;
  final Color dividerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: kPrimary.withValues(alpha: isDark ? 0.18 : 0.06),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: kPrimary,
                ),
                SizedBox(width: 6),
                Text(
                  'Accept Task',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Taken bar: greyed out, shows who already accepted ─────────────────────────

class _TakenBar extends StatelessWidget {
  const _TakenBar({
    required this.name,
    required this.isDark,
    required this.dividerColor,
  });

  final String name;
  final bool isDark;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white30 : Colors.black26;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 12, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Accepted by $name',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Status action bar: small chip for my-task status progression ──────────────

class _StatusActionBar extends StatelessWidget {
  const _StatusActionBar({
    required this.label,
    required this.color,
    required this.isDark,
    required this.dividerColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isDark;
  final Color dividerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const icon = Icons.arrow_circle_right_outlined;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: dividerColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 13, color: color),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
