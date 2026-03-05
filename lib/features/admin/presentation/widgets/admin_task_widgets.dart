import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task_card.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task_empty_state.dart';

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
          return Padding(
            padding: kItemSpacing,
            child: TaskCard(
              task: task,
              highlighted: task.status == TaskStatus.inProgress && i == 0,
              onToggle: () {},
              onDelete: () => ctrl.deleteTask(task.id),
              onTap: () {},
            ),
          );
        },
      );
    });
  }
}
