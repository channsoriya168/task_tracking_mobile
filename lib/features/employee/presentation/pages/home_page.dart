import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_chart_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/home_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_card.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_empty_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final homeCtrl = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting header ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : kTextMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Alex Johnson',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : kTextDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircularIconButton(
                    isDark: isDark,
                    icon: isDark ? Icons.light_mode : Icons.dark_mode,
                    onTap: () => themeCtrl.toggle(),
                  ),
                ],
              ),
            ),

            // ── Week calendar ─────────────────────────────────
            Padding(
              padding: kPageSectionPadding,
              child: Obx(
                () => WeekCalendarWidget(
                  isDark: isDark,
                  selectedDate: homeCtrl.selectedDate.value,
                  onDateSelected: homeCtrl.selectDate,
                ),
              ),
            ),
            // ── Status filter bar ─────────────────────────────
            TaskFilterBarWidget(
              isDark: isDark,
              filterStatus: homeCtrl.filterStatus,
              taskStatus: homeCtrl.taskStatus,
              allTasks: homeCtrl.allTasks,
              onSelectStatus: homeCtrl.selectStatus,
            ),

            // ── Search bar ────────────────────────────────────
            SearchBarWidget(
              isDark: isDark,
              onChanged: (v) => homeCtrl.searchQuery.value = v,
            ),
            Expanded(
              child: Obx(() {
                if (homeCtrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = homeCtrl.filteredTasks;
                if (tasks.isEmpty) return TaskEmptyState(isDark: isDark);
                return ListView.builder(
                  padding: kPageBottomPadding,
                  itemCount: tasks.length,
                  itemBuilder: (_, i) {
                    final task = tasks[i];
                    return Padding(
                      padding: kItemSpacing,
                      child: EmployeeTaskCard(task: task, isDark: isDark),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
