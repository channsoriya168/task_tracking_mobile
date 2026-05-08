import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/offline_card_widget.dart';
import 'package:task_tracking_mobile/features/label/presentation/pages/label_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/tablet_search_field_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_list_widget.dart';

class TaskTabletPage extends StatelessWidget {
  const TaskTabletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final auth = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offline = !Get.find<NetworkController>().isConnected.value;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = constraints.maxHeight < 320;
            final showExtendedHeader = !isKeyboardOpen && !isCompactHeight;

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: Title + Search + Labels button ─────────
                    Padding(
                      padding: kPagePaddingHorizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'task_title'.tr,
                            style: AppTextStyles.appBarTitle(
                              color: isDark ? Colors.white : kPrimary,
                            ),
                          ),
                          const Spacer(),
                          TabletSearchFieldWidget(
                            isDark: isDark,
                            onChanged: (v) => ctrl.searchQuery.value = v,
                            hintText: 'search'.tr,
                          ),
                          const SizedBox(width: 8),
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

                    if (showExtendedHeader) ...[
                      // ── Row 2: Filter bar ─────────────────────────────
                      // const SizedBox(height: 8),
                      TaskFilterBarWidget(
                        isDark: isDark,
                        filterStatus: ctrl.filterStatus,
                        taskStatus: ctrl.taskStatus,
                        allTasks: ctrl.allTasks,
                        onSelectStatus: ctrl.selectStatus,
                      ),

                      // ── Week calendar ─────────────────────────────────
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: Obx(
                          () => WeekCalendarWidget(
                            isDark: isDark,
                            selectedDate: ctrl.taskSelectedDate.value,
                            onDateSelected: ctrl.selectTaskDate,
                          ),
                        ),
                      ),
                    ],

                    // ── Task list ─────────────────────────────────────
                    Expanded(
                      child: RefreshIndicator(
                        color: kPrimary,
                        onRefresh: () => ctrl.fetchTasks(),
                        child: TaskListWidget(
                          isDark: isDark,
                          taskController: ctrl,
                        ),
                      ),
                    ),
                  ],
                ),
                if (offline) OfflineCardWidget(isDark: isDark),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ctrl.showTaskSheet(),
        backgroundColor: kPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
