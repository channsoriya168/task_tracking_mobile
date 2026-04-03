import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_shimmer_widget.dart';

class EmployeeListWidget extends StatelessWidget {
  const EmployeeListWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show shimmer while loading
      if (ctrl.isLoading.value) {
        return EmployeeListShimmer(isDark: isDark);
      }

      final employees = ctrl.filteredEmployees;
      if (employees.isEmpty) {
        return Center(
          child: Text(
            'No employees found.',
            style: TextStyle(color: isDark ? Colors.grey[500] : kTextMuted),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final emp = employees[i];
          final taskGroup = Get.find<TaskGroupController>()
              .taskGroupForEmployee(emp);
          return EmployeeCardWidget(
            isDark: isDark,
            ctrl: ctrl,
            employee: emp,
            taskGroup: taskGroup,
          );
        },
      );
    });
  }
}
