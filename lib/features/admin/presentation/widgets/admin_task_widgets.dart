import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/label/admin_label_page.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/filter_chip_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_empty_state.dart';

// ── Header ─────────────────────────────────────────────────────
class AdminTaskHeader extends StatelessWidget {
  const AdminTaskHeader({super.key, required this.isDark, required this.ctrl});

  final bool isDark;
  final AdminTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              Obx(
                () => Text(
                  '${ctrl.tasks.length} tasks',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => Get.to(() => const AdminLabelPage()),
            icon: const Icon(Icons.label_outline_rounded, size: 16),
            label: const Text('Labels'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar ─────────────────────────────────────────────────
class AdminTaskFilterBar extends StatelessWidget {
  const AdminTaskFilterBar({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final AdminTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Obx(() {
        final selected = ctrl.filterStatus.value;
        final statusItems = [null, ...ctrl.taskStatus]; // null = "All"

        final counts = <String, int>{
          'All': ctrl.tasks.length,
          for (final s in ctrl.taskStatus)
            s.name: ctrl.tasks
                .where(
                  (t) => t.status.name.toLowerCase() == s.name.toLowerCase(),
                )
                .length,
        };

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          itemCount: statusItems.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final status = statusItems[i];
            final label = status?.name ?? 'All';
            final isSelected = selected == label;
            final count = counts[label] ?? 0;

            return FilterChipWidget(
              isDark: isDark,
              filter: label,
              count: count,
              selected: isSelected,
              onTap: () => ctrl.selectStatus(status),
            );
          },
        );
      }),
    );
  }
}

// ── Task List ──────────────────────────────────────────────────
class AdminTaskList extends StatelessWidget {
  const AdminTaskList({super.key, required this.isDark, required this.ctrl});

  final bool isDark;
  final AdminTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final tasks = ctrl.filteredTasks;
      if (tasks.isEmpty) return TaskEmptyState(isDark: isDark);
      return ListView.builder(
        padding: kPageBottomPadding,
        itemCount: tasks.length,
        itemBuilder: (_, i) {
          final task = tasks[i];
          return Padding(
            padding: kItemSpacing,
            child: AdminTaskCard(
              task: task,
              isDark: isDark,
              onDelete: () => ctrl.deleteTask(task),
            ),
          );
        },
      );
    });
  }
}

// ── Admin Task Card ────────────────────────────────────────────
class AdminTaskCard extends StatelessWidget {
  const AdminTaskCard({
    super.key,
    required this.task,
    required this.isDark,
    required this.onDelete,
  });

  final TaskItem task;
  final bool isDark;
  final VoidCallback onDelete;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmt(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? kCardDark : Colors.white;
    final mutedColor = isDark ? Colors.white54 : kTextMuted;

    final statusColor = task.status.color;
    final priorityColor = task.priority.color;

    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status.name.toLowerCase() != 'completed' &&
        task.status.name.toLowerCase() != 'cancelled';

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kHighPriority.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: kHighPriority,
          size: 22,
        ),
      ),
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
                // ── Left accent strip ──
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
                // ── Content ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1 — title + menu
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : kTextDark,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            _CardMenu(
                              onDelete: onDelete,
                              isDark: isDark,
                              mutedColor: mutedColor,
                            ),
                          ],
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
                            Text(
                              _fmt(
                                task.startDate ??
                                    task.createdAt ??
                                    DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedColor,
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
                              Icon(
                                isOverdue
                                    ? Icons.warning_amber_rounded
                                    : Icons.event_rounded,
                                size: 11,
                                color: isOverdue ? kHighPriority : statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _fmt(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isOverdue
                                      ? kHighPriority
                                      : statusColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Row 4 — status · priority · label · assignee
                        Row(
                          children: [
                            StatusBadgeWidget(
                              label: task.status.name,
                              color: statusColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            // Priority dot
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
                            if ((task.labelName ?? task.groupName) != null) ...[
                              const SizedBox(width: 8),
                              _NeutralChip(
                                label: task.labelName ?? task.groupName!,
                                isDark: isDark,
                              ),
                            ],
                            const Spacer(),
                            if (task.assignedToName != null) ...[
                              _SingleAvatar(name: task.assignedToName!),
                              const SizedBox(width: 4),
                              Text(
                                task.assignedToName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
                                ),
                              ),
                            ] else if (task.createdByEmployeeName != null) ...[
                              _SingleAvatar(
                                name: task.createdByEmployeeName!,
                                color: mutedColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.createdByEmployeeName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
                                ),
                              ),
                            ],
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

// ── Neutral chip ───────────────────────────────────────────────
class _NeutralChip extends StatelessWidget {
  const _NeutralChip({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final fg = isDark ? Colors.white60 : kTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}

// ── Single avatar ──────────────────────────────────────────────
class _SingleAvatar extends StatelessWidget {
  const _SingleAvatar({required this.name, this.color});
  final String name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? kPrimary;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: c),
      ),
    );
  }
}

// ── Card Menu ─────────────────────────────────────────────────
class _CardMenu extends StatelessWidget {
  const _CardMenu({
    required this.onDelete,
    required this.isDark,
    required this.mutedColor,
  });
  final VoidCallback onDelete;
  final bool isDark;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _show(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.more_horiz_rounded, size: 18, color: mutedColor),
      ),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? kSurfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: kHighPriority,
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: kHighPriority),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
