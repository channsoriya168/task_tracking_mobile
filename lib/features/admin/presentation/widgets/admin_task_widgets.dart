import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/pages/tasks/task_view_page.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_empty_state.dart';

// ── Header ─────────────────────────────────────────────────────
class AdminTaskHeader extends StatelessWidget {
  const AdminTaskHeader({super.key, required this.isDark, required this.ctrl});

  final bool isDark;
  final AdminTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
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
              '${ctrl.filteredTasks.length} of ${ctrl.tasks.length} tasks',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : kTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar ─────────────────────────────────────────────────
const _kFilters = ['All', 'Pending', 'In Progress', 'Complete', 'Fail'];

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
        final currentFilter = ctrl.filterStatus.value;
        final counts = {
          for (final f in _kFilters) f: ctrl.countByStatus(f),
        };
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          itemCount: _kFilters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final filter = _kFilters[i];
            final selected = currentFilter == filter;
            final count = counts[filter] ?? 0;
            return _FilterChip(
              isDark: isDark,
              filter: filter,
              count: count,
              selected: selected,
              onTap: () => ctrl.filterStatus.value = filter,
            );
          },
        );
      }),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.isDark,
    required this.filter,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final bool isDark;
  final String filter;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: kButtonPaddingSmall,
        decoration: BoxDecoration(
          color: selected ? kTextDark : (isDark ? kCardDark : Colors.white),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white54 : kTextMuted),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: kItemSpacingSmall,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : kPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────
class AdminTaskSearchBar extends StatelessWidget {
  const AdminTaskSearchBar({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final AdminTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPageSectionPadding,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (v) => ctrl.searchQuery.value = v,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : kTextDark,
          ),
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : kTextMuted,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey[600] : kTextMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
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
      final tasks = ctrl.filteredTasks;
      if (tasks.isEmpty) return TaskEmptyState(isDark: isDark);
      return ListView.builder(
        padding: kPageBottomPadding,
        itemCount: tasks.length,
        itemBuilder: (_, i) {
          final task = tasks[i];
          final canView = task.status == TaskStatus.inProgress ||
              task.status == TaskStatus.done;
          return Padding(
            padding: kItemSpacing,
            child: AdminTaskCard(
              task: task,
              onDelete: () => ctrl.deleteTask(task.id),
              onTap: canView
                  ? () => Get.to(() => TaskViewPage(task: task))
                  : null,
            ),
          );
        },
      );
    });
  }
}

// ── Admin Task Card ────────────────────────────────────────────
//
// Layout:
//  ┌──────────────────────────────────────────────────┐
//  │  ENGINEERING                        ● High  ···  │  meta row
//  │                                                  │
//  │  Fix authentication bug when user               │  title
//  │  logs in from multiple devices                   │
//  │                                                  │
//  │  ── ── ── ── ── ── ── ── ── ── ── ── ── ── ──  │  divider
//  │                                                  │
//  │  ⚠ Overdue · 3 Mar 2026              [J D]      │  footer
//  ├══════════════════════════════════════════════════╡  progress strip
//  └──────────────────────────────────────────────────┘
//
class AdminTaskCard extends StatelessWidget {
  const AdminTaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onTap,
  });

  final TaskModel task;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : const Color(0xFFD1D5DB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final mutedColor = isDark ? Colors.white38 : const Color(0xFF9CA3AF);
    final isOverdue = task.isOverdue;

    // Progress data
    final done = task.progressItems.where((s) => s.startsWith('[x]')).length;
    final total = task.progressItems.length;
    final progressValue =
        total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Dismissible(
      key: Key(task.id),
      direction: task.status == TaskStatus.done
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: kHighPriority.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: kHighPriority.withValues(alpha: 0.2),
          ),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: kHighPriority, size: 20),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Meta row: category · priority · menu ──
                      Row(
                        children: [
                          Text(
                            task.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: _categoryColor(task.category),
                            ),
                          ),
                          const Spacer(),
                          _PriorityTag(task: task),
                          const SizedBox(width: 6),
                          _CardMenu(
                            onEdit: onTap,
                            onDelete: onDelete,
                            isDark: isDark,
                            mutedColor: mutedColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ── Title ──────────────────────────────────
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Divider ────────────────────────────────
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.black.withValues(alpha: 0.08),
                      ),

                      const SizedBox(height: 12),

                      // ── Footer ─────────────────────────────────
                      Row(
                        children: [
                          // Status + date
                          Icon(
                            isOverdue
                                ? Icons.error_outline_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13,
                            color: isOverdue
                                ? kHighPriority
                                : task.statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _footerLabel(isOverdue),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverdue ? kHighPriority : mutedColor,
                            ),
                          ),
                          const Spacer(),
                          // Assignee
                          if (task.acceptedBy != null)
                            _AssigneeChip(
                              name: task.acceptedBy!,
                              isDark: isDark,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Progress strip at bottom ───────────────
                if (task.status == TaskStatus.inProgress)
                  _ProgressStrip(
                    value: progressValue,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _footerLabel(bool isOverdue) {
    final statusPart = task.statusLabel;
    if (task.dueDate == null) return statusPart;
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = task.dueDate!;
    final datePart = '${d.day} ${m[d.month - 1]}';
    return isOverdue ? 'Overdue · $datePart' : '$statusPart · $datePart';
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Meeting':       return const Color(0xFF1976D2);
      case 'Engineering':   return const Color(0xFF6B3FA0);
      case 'Design':        return const Color(0xFFD81B60);
      case 'Research':      return const Color(0xFF00838F);
      case 'Documentation': return const Color(0xFFF57C00);
      case 'Marketing':     return const Color(0xFF8E24AA);
      case 'Maintenance':   return const Color(0xFF546E7A);
      default:              return kTextMuted;
    }
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _PriorityTag extends StatelessWidget {
  const _PriorityTag({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final color = task.priorityColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          task.priorityLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({
    required this.onEdit,
    required this.onDelete,
    required this.isDark,
    required this.mutedColor,
  });
  final VoidCallback? onEdit;
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
            if (onEdit != null)
              ListTile(
                leading: Icon(Icons.visibility_outlined,
                    color: isDark ? Colors.white70 : kTextDark),
                title: Text('View Details',
                    style: TextStyle(
                        color: isDark ? Colors.white : kTextDark)),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: kHighPriority),
              title: const Text('Delete',
                  style: TextStyle(color: kHighPriority)),
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

class _AssigneeChip extends StatelessWidget {
  const _AssigneeChip({required this.name, required this.isDark});
  final String name;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase())
        .take(2)
        .join();
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: kPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: kPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.value, required this.isDark});
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor:
            isDark ? Colors.white12 : kPrimary.withValues(alpha: 0.08),
        valueColor: AlwaysStoppedAnimation(
          value >= 1.0 ? kLowPriority : kPrimary,
        ),
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
