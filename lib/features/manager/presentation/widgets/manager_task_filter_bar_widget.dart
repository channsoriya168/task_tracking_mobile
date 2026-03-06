// ── Filter Bar ─────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/filter_chip_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';

const _kFilters = ['All', 'Pending', 'In Progress', 'Complete', 'Fail'];

class ManagerTaskFilterBarWidget extends StatelessWidget {
  const ManagerTaskFilterBarWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final ManagerTaskController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Obx(() {
        final currentFilter = ctrl.filterStatus.value;
        final counts = {for (final f in _kFilters) f: ctrl.countByStatus(f)};
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          itemCount: _kFilters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final filter = _kFilters[i];
            final selected = currentFilter == filter;
            final count = counts[filter] ?? 0;
            return FilterChipWidget(
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
