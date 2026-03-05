// ── Right Panel ────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_grid_card_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/panel_header_widget.dart';

class RightEmployeePanelWidget extends StatelessWidget {
  const RightEmployeePanelWidget({
    required this.isDark,
    required this.ctrl,
    required this.selectedPositionId,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final String? selectedPositionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelHeaderWidget(
          isDark: isDark,
          ctrl: ctrl,
          selectedPositionId: selectedPositionId,
        ),
        EmployeeSearchBar(
          isDark: isDark,
          ctrl: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        ),
        Expanded(
          child: Obx(() {
            final employees = selectedPositionId == null
                ? ctrl.filteredEmployees
                : ctrl.employeesByPosition(selectedPositionId!);

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
                final pos = ctrl.findPosition(emp.positionId);
                return EmployeeGridCardWidget(
                  isDark: isDark,
                  ctrl: ctrl,
                  employee: emp,
                  position: pos,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
