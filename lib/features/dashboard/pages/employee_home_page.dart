import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/controllers/employee_home_controller.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/action_card_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/task_card_shimmer.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/pages/employee_task_page.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_task_card.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_empty_state.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<EmployeeHomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Tracking',
          style: AppTextStyles.appBarTitle(color: kPrimary),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await homeCtrl.fetchTasks();
            await homeCtrl.fetchStatuses();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? kBgDark : kBgLight,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.22)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    kPrimary.withValues(alpha: 0.90),
                                    kPrimary.withValues(alpha: 0.70),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimary.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.dashboard_customize_rounded,
                                size: 19,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dashboard'.tr,
                                  style: AppTextStyles.appBarTitle(
                                    color: kPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withValues(alpha: 0.08),
                                          Colors.white.withValues(alpha: 0.03),
                                        ]
                                      : [
                                          Colors.black.withValues(alpha: 0.02),
                                          Colors.black.withValues(alpha: 0.01),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Text(
                                'today'.tr,
                                style: AppTextStyles.subTitle(
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black.withValues(alpha: 0.58),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Obx(() {
                          final allTasks = homeCtrl.allTasks;
                          final employeeId = Get.find<ProfileController>()
                              .profile
                              .value
                              ?.employeeId;

                          final myTasksCount = allTasks
                              .where((t) => t.assignedToId == employeeId)
                              .length;
                          final allTasksCount = allTasks.length;
                          final employeesCount = allTasks
                              .map((t) => t.assignedToId)
                              .whereType<String>()
                              .where((id) => id.trim().isNotEmpty)
                              .toSet()
                              .length;

                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final itemWidth =
                                    (constraints.maxWidth - 10) / 2;
                                return Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'all_tasks'.tr,
                                      value: allTasksCount,
                                      icon: Icons.fact_check_rounded,
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'my_tasks'.tr,
                                      value: myTasksCount,
                                      icon: Icons.assignment_ind_rounded,
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'employees'.tr,
                                      value: employeesCount,
                                      icon: Icons.group_rounded,
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'attendance'.tr,
                                      value: 0,
                                      icon: Icons.check_circle_rounded,
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'leave'.tr,
                                      value: 0,
                                      icon: Icons.check_circle_rounded,
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'absent'.tr,
                                      value: 0,
                                      icon: Icons.check_circle_rounded,
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ActionCardWidget(
                    isDark: isDark,
                    icon: Icons.task_alt_rounded,
                    title: 'my_tasks'.tr,
                    subtitle: 'View your assigned tasks'.tr,
                    onTap: () => Get.to(() => const EmployeeTaskPage()),
                  ),
                  const SizedBox(height: 10),
                  ActionCardWidget(
                    isDark: isDark,
                    icon: Icons.access_time_filled_rounded,
                    title: 'attendance'.tr,
                    subtitle: 'check_in_and_check_out_today'.tr,
                    actionLabel: 'check_in'.tr,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ActionCardWidget(
                    isDark: isDark,
                    icon: Icons.access_time_filled_rounded,
                    title: 'leave'.tr,
                    subtitle: 'apply_for_leave'.tr,
                    onTap: () => Get.to(() => AppRoutes.attendance),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'recent_tasks'.tr,
                        style: AppTextStyles.buttonLabel(
                          color: isDark
                              ? Colors.white
                              : Colors.black.withValues(alpha: 0.90),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Obx(
                    () => WeekCalendarWidget(
                      isDark: isDark,
                      selectedDate: homeCtrl.selectedDate.value,
                      onDateSelected: homeCtrl.selectDate,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TaskFilterBarWidget(
                    isDark: isDark,
                    filterStatus: homeCtrl.filterStatus,
                    taskStatus: homeCtrl.taskStatus,
                    allTasks: homeCtrl.allTasks,
                    onSelectStatus: homeCtrl.selectStatus,
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final tasks = homeCtrl.filteredTasks;
                    if (homeCtrl.isLoading.value) {
                      return Column(
                        children: List.generate(
                          3,
                          (index) => TaskCardShimmer(isDark: isDark),
                        ),
                      );
                    } else if (tasks.isEmpty) {
                      return TaskEmptyState(isDark: isDark);
                    } else {
                      return Column(
                        children: tasks
                            .map(
                              (t) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: EmployeeTaskCard(
                                  task: t,
                                  isDark: isDark,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required bool isDark,
    required double width,
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? kBgDark : kBgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: isDark ? Colors.white : kPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subTitle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.74)
                        : Colors.black.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$value',
                  style: AppTextStyles.buttonLabel(
                    color: isDark
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.90),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
