// ── Filter Bar ─────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/filter_chip_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';

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
        final selected = ctrl.filterStatus.value;
        final statusItems = [null, ...ctrl.taskStatus]; // null = "All"

        // Compute counts inside Obx so ctrl.tasks is tracked reactively.
        final counts = <String, int>{
          'All': ctrl.tasks.length,
          for (final s in ctrl.taskStatus)
            s.name: ctrl.tasks
                .where(
                  (t) => t.status.name.toLowerCase() == s.name.toLowerCase(),
                )
                .length,
        };

        return Container(
          padding: kPagePaddingHorizontal,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
            itemCount: statusItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
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
          ),
        );
      }),
    );
  }
}
