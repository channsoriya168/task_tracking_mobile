import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDone = task.status == TaskStatus.done;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: kHighPriority, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: task.isOverdue
                ? Border.all(color: kHighPriority.withOpacity(0.4), width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isDone ? kPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDone
                          ? kPrimary
                          : (isDark ? const Color(0xFF4A4A6A) : Colors.grey.shade300),
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDone
                                  ? (isDark ? Colors.white38 : Colors.grey.shade400)
                                  : (isDark ? Colors.white : kTextDark),
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              decorationColor:
                                  isDark ? Colors.white38 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        // Priority dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: task.priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white.withOpacity(0.45)
                              : kTextMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _chip(task.category, Icons.folder_outlined, kPrimary),
                        const SizedBox(width: 6),
                        _chip(task.statusLabel, _statusIcon(task.status), task.statusColor),
                        const Spacer(),
                        if (task.dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: task.isOverdue
                                    ? kHighPriority
                                    : (isDark ? Colors.white38 : Colors.grey.shade400),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatDate(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: task.isOverdue
                                      ? kHighPriority
                                      : (isDark ? Colors.white38 : Colors.grey.shade500),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:       return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress: return Icons.timelapse_rounded;
      case TaskStatus.done:       return Icons.check_circle_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.inDays == 0 && diff.inHours >= 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays == -1) return 'Yesterday';
    if (diff.inDays < 0) return '${diff.inDays.abs()}d overdue';
    if (diff.inDays < 7) return 'In ${diff.inDays}d';
    final m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[date.month - 1]} ${date.day}';
  }
}