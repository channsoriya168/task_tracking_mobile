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
    final statusNorm = task.status.name
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '');

    final isPending = task.assignedToName == null;
    final isAssigned = statusNorm == 'assigned' &&
        task.assignedToId != null &&
        task.assignedToId == currentId;
    final isAssignedOther = statusNorm == 'assigned' &&
        task.assignedToId != null &&
        task.assignedToId != currentId;
    final isInProgress = statusNorm == 'inprogress' &&
        task.assignedToId != null &&
        task.assignedToId == currentId;
    final isInProgressOther = statusNorm == 'inprogress' &&
        task.assignedToId != null &&
        task.assignedToId != currentId;
    final isInReview = statusNorm == 'inreview' &&
        task.assignedToId != null &&
        task.assignedToId == currentId;
    final isInReviewOther = statusNorm == 'inreview' &&
        task.assignedToId != null &&
        task.assignedToId != currentId;
    final isCompleted = statusNorm == 'completed' || statusNorm == 'done';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
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
              // Left accent strip
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
              // Card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleRow(task: task, isDark: isDark),
                      if ((task.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: mutedColor, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _DateRow(task: task, isDark: isDark),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusBadgeWidget(
                            label: task.status.name,
                            color: statusColor,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _PriorityDot(color: task.priority.color),
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
                          if (isPending)
                            _CardActionChip(
                              label: 'Accept',
                              isDark: isDark,
                              onTap: onAccept ?? () {
                                ctrl.prepareTaskDetail(task.id);
                                showEmployeeTaskDetailSheet(context, isDark, task);
                              },
                            ),
                          if (isAssigned)
                            _CardActionChip(
                              label: 'In Progress',
                              isDark: isDark,
                              onTap: () {
                                ctrl.prepareTaskDetail(task.id, showMembers: true);
                                showEmployeeTaskDetailSheet(context, isDark, task,
                                    showMembers: true);
                              },
                            ),
                          if (isAssignedOther)
                            _CardActionChip(
                              label: 'View',
                              isDark: isDark,
                              muted: true,
                              onTap: () {
                                ctrl.prepareTaskDetail(task.id, showMembers: true);
                                showEmployeeTaskDetailSheet(context, isDark, task,
                                    showMembers: true, readOnly: true);
                              },
                            ),
                          if (isInProgress)
                            _CardActionChip(
                              label: 'Review',
                              isDark: isDark,
                              onTap: () {
                                ctrl.prepareTaskDetail(task.id, showProgress: true);
                                showEmployeeTaskDetailSheet(context, isDark, task,
                                    showProgress: true);
                              },
                            ),
                          if (isInProgressOther)
                            _CardActionChip(
                              label: 'View',
                              isDark: isDark,
                              muted: true,
                              onTap: () {
                                ctrl.prepareTaskDetail(task.id,
                                    showMembers: true, showProgress: true);
                                showEmployeeTaskDetailSheet(context, isDark, task,
                                    showMembers: true,
                                    showProgress: true,
                                    readOnly: true);
                              },
                            ),
                          if (isInReview)
                            _CardActionChip(
                              label: 'Complete',
                              isDark: isDark,
                              onTap: () {
                                ctrl.prepareTaskDetail(task.id,
                                    showMembers: true, showProgress: true);
                                showEmployeeTaskDetailSheet(context, isDark, task,
                                    showMembers: true,
                                    showProgress: true,
                                    showComplete: true);
                              },
                            ),
                          if (isCompleted)
                            _CardActionChip(
                              label: 'View',
                              isDark: isDark,
                              muted: true,
                              onTap: () {
                                ctrl.prepareTaskDetail(task.id,
                                    showMembers: true, showProgress: true);
                                showEmployeeTaskDetailSheet(context, isDark, task,
                                    showMembers: true,
                                    showProgress: true,
                                    readOnly: true);
                              },
                            ),
                          if (isInReviewOther)
                            _CardActionChip(
                              label: 'View',
                              isDark: isDark,
                              muted: true,
                              onTap: () {
                                ctrl.prepareTaskDetail(task.id,
                                    showMembers: true, showProgress: true);
                                showEmployeeTaskDetailSheet(context, isDark, task,
                                    showMembers: true,
                                    showProgress: true,
                                    readOnly: true);
                              },
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
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.task, required this.isDark});

  final TaskItem task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final label = task.labelName ?? task.groupName;
    return RichText(
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
          if (label != null)
            TextSpan(
              text: '  ($label)',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : kTextMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.task, required this.isDark});

  final TaskItem task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white54 : kTextMuted;
    final showItalic = task.startDate == null;
    final dateText = task.startDate != null
        ? formatDate(task.startDate!)
        : task.createdAt != null
            ? formatDate(task.createdAt!)
            : null;

    return Row(
      children: [
        Icon(Icons.today_rounded, size: 11, color: mutedColor),
        const SizedBox(width: 4),
        if (dateText != null)
          Text(
            dateText,
            style: TextStyle(
              fontSize: 11,
              color: mutedColor,
              fontStyle: showItalic ? FontStyle.italic : null,
            ),
          ),
        if (task.dueDate != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child:
                Icon(Icons.arrow_right_alt_rounded, size: 13, color: mutedColor),
          ),
          Text(
            formatDate(task.dueDate!),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _CardActionChip extends StatelessWidget {
  const _CardActionChip({
    required this.label,
    required this.isDark,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final bgColor = muted
        ? (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06))
        : kPrimary.withValues(alpha: 0.12);
    final borderColor = muted
        ? (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.12))
        : kPrimary.withValues(alpha: 0.3);
    final labelColor =
        muted ? (isDark ? Colors.white54 : kTextMuted) : kPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: labelColor),
        ),
      ),
    );
  }
}
