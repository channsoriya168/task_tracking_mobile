// ── Sticky toolbar delegate ───────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/controllers/employee_home_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_filter_bar_widget.dart';

class StickyToolbarDelegateWidget extends SliverPersistentHeaderDelegate {
  const StickyToolbarDelegateWidget({
    required this.isDark,
    required this.homeCtrl,
  });

  final bool isDark;
  final EmployeeHomeController homeCtrl;

  // WeekCalendar: padding-top 16 + card ~132  =  148
  // FilterBar: 52
  // SearchBar: padding-top 16 + 44  =  60
  // Total = 260
  static const double _height = 262;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(StickyToolbarDelegateWidget old) =>
      old.isDark != isDark || old.homeCtrl != homeCtrl;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bg = isDark ? kBgDark : kBgLight;
    return ColoredBox(
      color: bg,
      child: Column(
        children: [
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
          TaskFilterBarWidget(
            isDark: isDark,
            filterStatus: homeCtrl.filterStatus,
            taskStatus: homeCtrl.taskStatus,
            allTasks: homeCtrl.allTasks,
            onSelectStatus: homeCtrl.selectStatus,
          ),
          SearchBarWidget(
            isDark: isDark,
            onChanged: (v) => homeCtrl.searchQuery.value = v,
          ),
        ],
      ),
    );
  }
}
