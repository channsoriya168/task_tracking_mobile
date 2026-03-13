import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_task_dialog_widget.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_task_widgets.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';

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

          AdminTaskFilterBar(isDark: isDark, ctrl: ctrl),
          SearchBarWidget(
            isDark: isDark,
            onChanged: (value) => ctrl.searchQuery.value = value,
          ),
          Expanded(child: AdminTaskList(isDark: isDark, ctrl: ctrl)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAdminTaskDialog(context, isDark),
        backgroundColor: kPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
