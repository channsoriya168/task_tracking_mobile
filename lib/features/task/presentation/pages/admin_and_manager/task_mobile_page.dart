import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/core/widgets/offline_card_widget.dart';
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
          // ── Title ────────────────────────────────────────────
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
                const Spacer(),
                Obx(() {
                  if (auth.role != UserRole.admin) {
                    return const SizedBox.shrink();
                  }
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

          // ── Offline banner ────────────────────────────────────
          Obx(() {
            final offline = !Get.find<NetworkController>().isConnected.value;
            if (!offline || ctrl.isOfflineDialogOpen.value) return const SizedBox.shrink();
            return OfflineCardWidget(isDark: isDark);
          }),

          // ── Week calendar ─────────────────────────────────────
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
            child: RefreshIndicator(
              color: kPrimary,
              onRefresh: ctrl.fetchTasks,
              child: TaskListWidget(isDark: isDark, taskController: ctrl),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!Get.find<NetworkController>().isConnected.value) {
            ctrl.isOfflineDialogOpen.value = true;
            showNoInternetDialog(isDark: isDark, redirectCount: 1)
                .then((_) => ctrl.isOfflineDialogOpen.value = false);
            return;
          }
          ctrl.showTaskSheet();
        },
        backgroundColor: kPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
