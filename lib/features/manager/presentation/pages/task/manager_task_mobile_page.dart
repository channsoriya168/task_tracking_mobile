import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/task_dialog_wiget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_header_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_list_widget.dart';

class ManagerTaskMobilePage extends StatelessWidget {
  const ManagerTaskMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ManagerTaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ManagerTaskHeaderWidget(isDark: isDark, ctrl: ctrl),
          ManagerTaskFilterBarWidget(isDark: isDark, ctrl: ctrl),
          SearchBarWidget(
            isDark: isDark,
            onChanged: (value) => ctrl.searchQuery.value = value,
          ),
          Expanded(
            child: ManagerTaskList(isDark: isDark, managerTaskController: ctrl),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(context, isDark),
        backgroundColor: kPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
