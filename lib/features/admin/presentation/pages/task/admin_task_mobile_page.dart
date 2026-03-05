import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_task_widgets.dart';

class AdminTaskMobilePage extends StatelessWidget {
  const AdminTaskMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminTaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminTaskHeader(isDark: isDark, ctrl: ctrl),
          AdminTaskFilterBar(isDark: isDark, ctrl: ctrl),
          AdminTaskSearchBar(isDark: isDark, ctrl: ctrl),
          Expanded(child: AdminTaskList(isDark: isDark, ctrl: ctrl)),
        ],
      ),
    );
  }
}
