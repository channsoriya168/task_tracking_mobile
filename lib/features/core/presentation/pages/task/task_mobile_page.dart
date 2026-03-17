import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/label/admin_label_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/show_task_dialog.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_header_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_list_widget.dart';

class TaskMobilePage extends StatelessWidget {
  const TaskMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final auth = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TaskHeaderWidget(isDark: isDark, ctrl: ctrl),
              ),
              Obx(() {
                if (auth.role != UserRole.Admin) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const AdminLabelPage()),
                    icon: const Icon(Icons.label_outline_rounded, size: 16),
                    label: const Text('Labels'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          // ── Week calendar ──────────────────────────────────
          Padding(
            padding: kPageSectionPadding,
            child: Obx(
              () => WeekCalendarWidget(
                isDark: isDark,
                selectedDate: ctrl.taskSelectedDate.value,
                onDateSelected: ctrl.selectTaskDate,
              ),
            ),
          ),

          TaskFilterBarWidget(
            isDark: isDark,
            filterStatus: ctrl.filterStatus,
            taskStatus: ctrl.taskStatus,
            allTasks: ctrl.allTasks,
            onSelectStatus: ctrl.selectStatus,
          ),
          SearchBarWidget(
            isDark: isDark,
            onChanged: (value) => ctrl.searchQuery.value = value,
          ),
          Expanded(
            child: TaskListWidget(isDark: isDark, taskController: ctrl),
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
