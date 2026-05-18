import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/stacked_avatars_widget.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';

class EmployeeTaskCard extends StatelessWidget {
  const EmployeeTaskCard({
    super.key,
    required this.task,
    required this.isDark,
    this.onAccept,
  });

  final TaskItem task;
  final bool isDark;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeTaskController>();
    final currentId = ctrl.currentEmployeeId;

    final terminalStatuses = {'cancelled', 'completed'};
    final isPending =
        task.assignedToId == null &&
        !terminalStatuses.contains(task.status.name.toLowerCase());
    final isMyTask =
        task.assignedToId != null && task.assignedToId == currentId;
    final isAssignedToOther = task.assignedToId != null && !isMyTask;

    final transitions = isMyTask
        ? task.allowedTransitions
        : <TaskStatusLookup>[];
    final primaryTransition = transitions.isNotEmpty ? transitions.first : null;

    void openDetail({bool readOnly = false}) {
      ctrl.prepareTaskDetail(task.id);
      Get.toNamed(
        AppRoutes.taskDetail,
        arguments: {'task': task, 'isDark': isDark, 'readOnly': readOnly},
      );
    }

    final statusColor = task.status.color;

    // Due date label
    final now = DateTime.now();
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime(now.year, now.month, now.day));
    final isDueToday =
        task.dueDate != null &&
        task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;

    String? dueDateLabel;
    bool dueDateUrgent = false;
    if (task.completedAt != null) {
      dueDateLabel = 'task_done_date'.trParams({
        'date': formatDate(task.completedAt!),
      });
    } else if (isDueToday) {
      dueDateLabel = 'task_due_today'.tr;
      dueDateUrgent = true;
    } else if (isOverdue) {
      dueDateLabel = 'task_overdue_date'.trParams({
        'date': formatDate(task.dueDate!),
      });
      dueDateUrgent = true;
    } else if (task.dueDate != null) {
      dueDateLabel = 'task_due_date'.trParams({
        'date': formatDate(task.dueDate!),
      });
    }
    return GestureDetector(
      onTap: () => openDetail(readOnly: isAssignedToOther),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          // border: Border.all(color: kPrimary, width: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Card content ───────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title row + new badge + priority dot ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: AppTextStyles.title(
                                  color: isDark ? Colors.white : kTextDark,
                                ).copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StackedAvatarsWidget(
                              task: task,
                              mutedColor: isDark ? Colors.white54 : kTextMuted,
                            ),
                          ],
                        ),

                        // ── Description ───────────────────────
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            task.description!,
                            style: AppTextStyles.subTitle(
                              color: isDark ? Colors.white54 : kTextMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 12),

                        // ── Bottom row: avatar + action ────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ── Due date ──────────────────────────
                            if (dueDateLabel != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (dueDateUrgent)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: Icon(
                                              Icons.access_time_rounded,
                                              size: 13,
                                              color: dueDateUrgent
                                                  ? const Color(0xFFFF6B35)
                                                  : (isDark
                                                        ? Colors.white38
                                                        : const Color(
                                                            0xFF8E8EA0,
                                                          )),
                                            ),
                                          ),
                                        Text(
                                          dueDateLabel,
                                          style: AppTextStyles.subTitle(
                                            color: dueDateUrgent
                                                ? const Color(0xFFFF6B35)
                                                : (isDark
                                                      ? Colors.white38
                                                      : const Color(
                                                          0xFF8E8EA0,
                                                        )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const Spacer(),

                            // Action
                            if (isPending && !isOverdue)
                              _AcceptButton(
                                onTap: onAccept ?? () => openDetail(),
                              )
                            else if (isAssignedToOther)
                              _StatusChip(
                                label: task.status.localizedName,
                                color: statusColor,
                              )
                            else if (primaryTransition != null)
                              _StatusChip(
                                label: task.status.localizedName,
                                color: statusColor,
                                onTap: () => openDetail(),
                              )
                            else if (!isPending && !isAssignedToOther)
                              _StatusChip(
                                label: task.status.localizedName,
                                color: statusColor,
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

// ── Accept button ─────────────────────────────────────────────────────────────

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'task_accept'.tr,
          style: AppTextStyles.subTitle(
            color: Colors.white,
          ).copyWith(fontWeight: FontWeight.w600, letterSpacing: kLs(0.5)),
        ),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color, this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          // color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: AppTextStyles.subTitle(
            color: color,
          ).copyWith(fontWeight: FontWeight.w600, letterSpacing: kLs(0.5)),
        ),
      ),
    );
  }
}
