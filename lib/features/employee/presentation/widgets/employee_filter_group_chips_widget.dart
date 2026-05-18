import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/filter_chip_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';

class EmployeeFilterGroupChipsWidget extends StatelessWidget {
  const EmployeeFilterGroupChipsWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = ctrl.groups.toList();
      final selected = ctrl.selectedTaskGroupId.value;
      final all = ctrl.allEmployees;

      return Padding(
        padding: kPagePaddingHorizontal,
        child: SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // ── "All" chip ──────────────────────────────────
              FilterChipWidget(
                isDark: isDark,
                filter: 'employee_all'.tr,
                count: all.length,
                selected: selected.isEmpty,
                onTap: () => ctrl.selectedTaskGroupId.value = '',
              ),
              const SizedBox(width: 8),

              // ── Group chips ─────────────────────────────────
              ...groups.map((g) {
                final count = all
                    .where((e) => e.groups.any((eg) => eg.groupId == g.id))
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChipWidget(
                    isDark: isDark,
                    filter: g.name,
                    count: count,
                    selected: selected == g.id,
                    onTap: () => ctrl.selectedTaskGroupId.value = g.id,
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}
