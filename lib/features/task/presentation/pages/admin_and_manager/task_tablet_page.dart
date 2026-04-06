import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_list_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/show_task_dialog.dart';

class TaskTabletPage extends StatelessWidget {
  const TaskTabletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? kBgDark : kBgLight,
      child: Row(
        children: [
          // ── Left Panel: Filters ───────────────────────────
          SizedBox(
            width: 240,
            height: double.infinity,
            child: _FilterPanel(isDark: isDark, ctrl: ctrl),
          ),

          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),

          // ── Right Panel: Calendar + Task List ─────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ManagerTaskHeaderWidget(isDark: isDark, ctrl: ctrl),

                // Week calendar
                Padding(
                  padding: kPageSectionPadding,
                  child: Obx(
                    () => WeekCalendarWidget(
                      isDark: isDark,
                      selectedDate: ctrl.taskSelectedDate.value,
                      onDateSelected: ctrl.selectTaskDate,
                    ),
                  ),
                ),

                SearchBarWidget(
                  isDark: isDark,
                  onChanged: (value) => ctrl.searchQuery.value = value,
                ),
                Expanded(
                  child: TaskListWidget(isDark: isDark, taskController: ctrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Left Filter Panel ──────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.isDark, required this.ctrl});

  final bool isDark;
  final TaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
        ),

        // Dynamic status list from API — scrollable to prevent overflow
        Expanded(
          child: Obx(() {
            final current = ctrl.filterStatus.value;
            final statusItems = [null, ...ctrl.taskStatus];
            final counts = <String, int>{
              'All': ctrl.allTasks.length,
              for (final s in ctrl.taskStatus)
                s.name: ctrl.allTasks
                    .where(
                      (t) =>
                          t.status.name.toLowerCase() == s.name.toLowerCase(),
                    )
                    .length,
            };

            return ListView(
              padding: EdgeInsets.zero,
              children: statusItems.map((status) {
                final label = status?.name ?? 'All';
                final selected = current == label;
                final count = counts[label] ?? 0;
                return _FilterTile(
                  isDark: isDark,
                  label: label,
                  count: count,
                  selected: selected,
                  onTap: () => ctrl.selectStatus(status),
                );
              }).toList(),
            );
          }),
        ),

        // Create Task button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showTaskDialog(context, isDark),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Create Task',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Filter tile ────────────────────────────────────────────────
class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.isDark,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final bool isDark;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? kPrimary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? kPrimary
                    : (isDark ? Colors.white70 : kTextMuted),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? kPrimary.withValues(alpha: 0.15)
                    : (isDark ? kCardDark : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? kPrimary
                      : (isDark ? Colors.white54 : kTextMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
