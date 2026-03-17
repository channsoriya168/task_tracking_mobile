import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_group/task_group_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_group/task_group_dialog.dart';

class ManageTaskGroupWidget extends StatelessWidget {
  const ManageTaskGroupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskGroupController>();
    final employeeCtrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : kTextDark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Task Groups',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ),
      body: Obx(() {
        final positions = ctrl.taskGroups;
        if (positions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 60,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No task groups yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: positions.length,
          itemBuilder: (_, i) {
            final pos = positions[i];
            final count = employeeCtrl.employeeCountByTaskGroup(pos.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskGroupCardWidget(
                isDark: isDark,
                ctrl: ctrl,
                position: pos,
                employeeCount: count,
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => showTaskGroupDialog(context, ctrl, isDark),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
