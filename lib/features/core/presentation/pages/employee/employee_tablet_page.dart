import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_filter_task_group_dropdown_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_header_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_list_widget.dart';

class EmployeeTabletPage extends StatelessWidget {
  const EmployeeTabletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        children: [
          EmployeeHeaderWidget(isDark: isDark, ctrl: ctrl),
          EmployeeFilterTaskGroupDropdownWidget(isDark: isDark, ctrl: ctrl),
          SearchBarWidget(
            isDark: isDark,
            onChanged: (v) => ctrl.searchQuery.value = v,
            hintText: 'Search employees...',
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          ),
          Expanded(
            child: EmployeeListWidget(isDark: isDark, ctrl: ctrl),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => Get.find<EmployeeController>().showCreateDialog(),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}
