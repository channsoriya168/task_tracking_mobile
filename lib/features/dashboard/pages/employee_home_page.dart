import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/sticky_toolbar_delegate_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/task_card_shimmer.dart';
import 'package:task_tracking_mobile/features/dashboard/controllers/employee_home_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_task_card.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_empty_state.dart';

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
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await homeCtrl.fetchTasks();
            await homeCtrl.fetchStatuses();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // // ── Sticky: calendar + filter + search ────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyToolbarDelegateWidget(
                  isDark: isDark,
                  homeCtrl: homeCtrl,
                ),
              ),

              // ── Task list / shimmer / empty ───────────────────
              Obx(() {
                final offline =
                    !Get.find<NetworkController>().isConnected.value;
                if (homeCtrl.isLoading.value ||
                    (offline && homeCtrl.allTasks.isEmpty)) {
                  return SliverPadding(
                    padding: kPageBottomPadding,
                    sliver: SliverList.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, __) => TaskCardShimmer(isDark: isDark),
                    ),
                  );
                }
                final tasks = homeCtrl.filteredTasks;
                if (tasks.isEmpty) {
                  return SliverPadding(
                    padding: kPageBottomPadding,
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 280,
                        child: TaskEmptyState(isDark: isDark),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: kPagePaddingHorizontal,
                  sliver: SliverList.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        EmployeeTaskCard(task: tasks[i], isDark: isDark),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
