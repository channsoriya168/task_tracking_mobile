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
// Matches the ManagerTaskCardWidget layout:
//  ┌─┬──────────────────────────────────────────────┐
//  │▌│ Title                                   ···  │
//  │▌│ Description (1 line)                         │
//  │▌│ 📅 Created → ⚠ Due date                     │
//  │▌│ [Status] [Category]          [Avatar] Name   │
//  │▌├══════════════════════════════════════════════╡ progress
//  └─┴──────────────────────────────────────────────┘
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

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _fmt(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE5E7EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF9CA3AF);
    final isOverdue = task.isOverdue;
    final statusColor = isOverdue ? kHighPriority : task.statusColor;

    final doneProg = task.progressItems.where((s) => s.startsWith('[x]')).length;
    final totalProg = task.progressItems.length;
    final progressValue = totalProg == 0 ? 0.0 : (doneProg / totalProg).clamp(0.0, 1.0);

    return Dismissible(
      key: Key(task.id),
      direction: task.status == TaskStatus.done
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kHighPriority.withValues(alpha: 0.2)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: kHighPriority, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
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
                    child: Column(
                      children: [
                        Padding(
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
                                        color: titleColor,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                  _CardMenu(
                                    onView: onTap,
                                    onDelete: onDelete,
                                    isDark: isDark,
                                    mutedColor: mutedColor,
                                  ),
                                ],
                              ),
                              // Row 2 — description
                              if (task.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  task.description,
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
                              // Row 3 — dates
                              Row(
                                children: [
                                  Icon(Icons.today_rounded, size: 11, color: mutedColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    _fmt(task.createdAt),
                                    style: TextStyle(fontSize: 11, color: mutedColor),
                                  ),
                                  if (task.dueDate != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Icon(Icons.arrow_right_alt_rounded,
                                          size: 13, color: mutedColor),
                                    ),
                                    Icon(
                                      isOverdue
                                          ? Icons.warning_amber_rounded
                                          : Icons.event_rounded,
                                      size: 11,
                                      color: isOverdue ? kHighPriority : kPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _fmt(task.dueDate!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isOverdue ? kHighPriority : kPrimary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Row 4 — status · category · assignee
                              Row(
                                children: [
                                  _StatusBadge(
                                    label: isOverdue ? 'Overdue' : task.statusLabel,
                                    color: statusColor,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _StatusBadge(
                                    label: task.category,
                                    color: statusColor,
                                    isDark: isDark,
                                  ),
                                  const Spacer(),
                                  if (task.acceptedBy != null) ...[
                                    _AssigneeAvatar(name: task.acceptedBy!),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.acceptedBy!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: mutedColor),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ── Progress strip (inProgress only) ──────
                        if (task.status == TaskStatus.inProgress)
                          SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(
                              value: progressValue,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : kPrimary.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation(
                                progressValue >= 1.0 ? kLowPriority : kPrimary,
                              ),
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color, required this.isDark});
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _AssigneeAvatar extends StatelessWidget {
  const _AssigneeAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: kPrimary),
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({
    required this.onView,
    required this.onDelete,
    required this.isDark,
    required this.mutedColor,
  });
  final VoidCallback? onView;
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
            if (onView != null)
              ListTile(
                leading: Icon(Icons.visibility_outlined,
                    color: isDark ? Colors.white70 : kTextDark),
                title: Text('View Details',
                    style: TextStyle(color: isDark ? Colors.white : kTextDark)),
                onTap: () { Navigator.pop(context); onView!(); },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: kHighPriority),
              title: const Text('Delete', style: TextStyle(color: kHighPriority)),
              onTap: () { Navigator.pop(context); onDelete(); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

