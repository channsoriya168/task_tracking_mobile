import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/constants/user_role.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/core/widgets/offline_card_widget.dart';
import 'package:task_tracking_mobile/core/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/label/presentation/pages/label_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/core/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_bottom_sheet.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_list_widget.dart';

class TaskMobilePage extends StatelessWidget {
  const TaskMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final auth = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'task_title'.tr,
          style: AppTextStyles.appBarTitle(color: kPrimary),
        ),
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        actions: [
          Obx(() {
            if (auth.role != UserRole.admin) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: kPagePaddingHorizontal,
              child: OutlinedButton.icon(
                onPressed: () => Get.to(() => const LabelPage()),
                label: Text(
                  'task_create_labels'.tr,
                  style: AppTextStyles.buttonLabel(color: kPrimary),
                ),
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
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Offline banner ────────────────────────────────────
          Obx(() {
            final offline = !Get.find<NetworkController>().isConnected.value;
            if (!offline || ctrl.isOfflineDialogOpen.value)
              return const SizedBox.shrink();
            return OfflineCardWidget(isDark: isDark);
          }),

          // ── Week calendar ─────────────────────────────────────
          Padding(
            padding: kPagePaddingHorizontal,
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
            hintText: 'task_search_hint'.tr,
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () async {
          if (!Get.find<NetworkController>().isConnected.value) {
            ctrl.isOfflineDialogOpen.value = true;
            showNoInternetDialog(
              isDark: isDark,
              redirectCount: 1,
            ).then((_) => ctrl.isOfflineDialogOpen.value = false);
            return;
          }
          final groupCtrl = Get.find<GroupController>();
          final futures = <Future<void>>[ctrl.refreshFormData(), ctrl.fetchLabels()];
          if (groupCtrl.groups.isEmpty) futures.add(groupCtrl.fetchGroups());
          await Future.wait(futures);
          final groups = groupCtrl.groups.toList();
          ctrl.resetForm(groups);
          Get.bottomSheet(
            const TaskBottomSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        backgroundColor: kPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
        label: Text(
          'task_create'.tr,
          style: AppTextStyles.buttonLabel(color: Colors.white),
        ),
      ),
    );
  }
}
