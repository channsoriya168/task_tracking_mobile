// ── Filter Bar ─────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          itemCount: ctrl.taskStatus.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = ctrl.taskStatus[i];
            final selected = ctrl.filterStatus.value == f.name;
            final count = ctrl.countByStatus(f.name);
            return Text(
              f.name,
            ); // Placeholder, replace with actual FilterChipWidget
            // return FilterChipWidget(
            //   isDark: isDark,
            //   filter: f.name,
            //   count: count,
            //   selected: selected,
            //   onTap: () => ctrl.filterStatus.value = f.name,
            // );
          },
        );
      }),
    );
  }
}
