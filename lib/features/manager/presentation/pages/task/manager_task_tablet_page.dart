import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/task_dialog_wiget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_header_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_list_widget.dart';

class ManagerTaskTabletPage extends StatelessWidget {
  const ManagerTaskTabletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ManagerTaskController>();
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
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),

          // ── Right Panel: Task List ────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ManagerTaskHeaderWidget(isDark: isDark, ctrl: ctrl),
                SearchBarWidget(
                  isDark: isDark,
                  onChanged: (value) => ctrl.searchQuery.value = value,
                ),
                Expanded(
                  child: ManagerTaskList(
                    isDark: isDark,
                    managerTaskController: ctrl,
                  ),
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
const _kFilters = ['All', 'Pending', 'In Progress', 'Complete', 'Fail'];

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.isDark, required this.ctrl});

  final bool isDark;
  final ManagerTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Text(
            'Filter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
        ),
        Obx(() {
          final current = ctrl.filterStatus.value;
          return Column(
            children: _kFilters.map((filter) {
              final selected = current == filter;
              final count = ctrl.countByStatus(filter);
              return _FilterTile(
                isDark: isDark,
                filter: filter,
                count: count,
                selected: selected,
                onTap: () => ctrl.filterStatus.value = filter,
              );
            }).toList(),
          );
        }),
        const Spacer(),
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

class _FilterTile extends StatelessWidget {
  const _FilterTile({
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
              filter,
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
