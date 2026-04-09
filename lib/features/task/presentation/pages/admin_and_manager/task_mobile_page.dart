import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/label/presentation/pages/label_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_list_widget.dart';

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
          Padding(
            padding: kPagePaddingHorizontal,
            child: Row(
              children: [
                Text(
                  'task_title'.tr,
                  style: AppTextStyles.appBarTitle(
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                Spacer(),
                Obx(() {
                  if (auth.role != UserRole.admin)
                    return const SizedBox.shrink();
                  return OutlinedButton.icon(
                    onPressed: () => Get.to(() => const LabelPage()),
                    label: Text('task_create_labels'.tr),
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
                  );
                }),
              ],
            ),
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
        onPressed: () => ctrl.showTaskSheet(),
        backgroundColor: kPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
