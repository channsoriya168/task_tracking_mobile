import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_group_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_task_group_card_widget.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_task_group_dialog.dart';

class AdminTaskGroupPage extends StatelessWidget {
  const AdminTaskGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminTaskGroupController>();
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
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.taskGroups.isEmpty) {
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
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first task group',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[600] : kTextMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: ctrl.taskGroups.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AdminTaskGroupCardWidget(
              isDark: isDark,
              ctrl: ctrl,
              taskGroup: ctrl.taskGroups[i],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => showAdminTaskGroupDialog(context, ctrl, isDark),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
