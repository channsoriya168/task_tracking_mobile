import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/action_card_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/sticky_toolbar_delegate_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/task_card_shimmer.dart';
import 'package:task_tracking_mobile/features/dashboard/controllers/employee_home_controller.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_task_card.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_empty_state.dart';
import 'package:task_tracking_mobile/features/task/presentation/pages/employee_task_page.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<EmployeeHomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await homeCtrl.fetchTasks();
            await homeCtrl.fetchStatuses();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF171826), const Color(0xFF10111A)]
                            : [Colors.white, const Color(0xFFF7F9FF)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.30)
                              : kPrimary.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    kPrimary.withValues(alpha: 0.90),
                                    const Color(0xFF8B84FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.dashboard_customize_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'quick_actions'.tr,
                              style: AppTextStyles.buttonLabel(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black.withValues(alpha: 0.90),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimary.withValues(
                                  alpha: isDark ? 0.22 : 0.10,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'today'.tr,
                                style: AppTextStyles.caption(
                                  color: isDark
                                      ? Colors.white
                                      : kPrimary.withValues(alpha: 0.90),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                          final doneCount = _countCompletedTasks(allTasks);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : kPrimary.withValues(alpha: 0.035),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : kPrimary.withValues(alpha: 0.11),
                              ),
                            ),
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
                                      title: 'My Tasks',
                                      value: myTasksCount,
                                      icon: Icons.assignment_ind_rounded,
                                      accent: const Color(0xFF6D5DF6),
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'All Tasks',
                                      value: allTasksCount,
                                      icon: Icons.fact_check_rounded,
                                      accent: const Color(0xFF00A8E8),
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'Employees',
                                      value: employeesCount,
                                      icon: Icons.group_rounded,
                                      accent: const Color(0xFFFF9F1C),
                                    ),
                                    _buildMetricChip(
                                      isDark: isDark,
                                      width: itemWidth,
                                      title: 'Completed',
                                      value: doneCount,
                                      icon: Icons.check_circle_rounded,
                                      accent: const Color(0xFF2FBF71),
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
                  //action
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _countCompletedTasks(List<dynamic> tasks) {
    bool isDoneStatus(String statusName) {
      final n = statusName.trim().toLowerCase();
      return n == 'done' ||
          n == 'completed' ||
          n == 'complete' ||
          n == 'resolved' ||
          n == 'closed';
    }

    return tasks
        .where((t) => t.status.name.isNotEmpty && isDoneStatus(t.status.name))
        .length;
  }

  Widget _buildMetricChip({
    required bool isDark,
    required double width,
    required String title,
    required int value,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.25 : 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: isDark ? Colors.white : accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.72)
                        : Colors.black.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$value',
                  style: AppTextStyles.buttonLabel(
                    color: isDark
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.88),
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
