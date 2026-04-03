// ── Right Panel ────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/panel_header_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_grid_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_shimmer_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';

class RightPanelEmployeeWidget extends StatelessWidget {
  const RightPanelEmployeeWidget({
    required this.isDark,
    required this.ctrl,
    required this.selectedGroupId,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final String? selectedGroupId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelHeaderWidget(
          isDark: isDark,
          ctrl: ctrl,
          selectedTaskGroupId: selectedGroupId,
        ),
        SearchBarWidget(
          isDark: isDark,
          onChanged: (v) => ctrl.searchQuery.value = v,
          hintText: 'Search employees...',
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        ),
        Expanded(
          child: Obx(() {
            // Show shimmer while loading
            if (ctrl.isLoading.value) {
              return EmployeeGridShimmer(isDark: isDark);
            }

            final employees = ctrl.filteredEmployees;
            final groups = Get.find<GroupController>().groups;

            if (employees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      size: 56,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ctrl.searchQuery.value.isNotEmpty
                          ? 'No results found'
                          : 'No employees here yet',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 88,
              ),
              itemCount: employees.length,
              itemBuilder: (_, i) {
                final emp = employees[i];
                final groupId = emp.groups.isNotEmpty
                    ? emp.groups.first.groupId
                    : null;
                final group = groupId != null
                    ? groups.firstWhereOrNull((g) => g.id == groupId)
                    : null;
                return EmployeeGridCardWidget(
                  isDark: isDark,
                  ctrl: ctrl,
                  employee: emp,
                  group: group,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
