import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/offline_card_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/task_line_chart_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/widgets/task_shimmer_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminTaskCtrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white54 : kTextMuted;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.07);
    final cardShadow = BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
      blurRadius: 10,
      offset: const Offset(0, 3),
    );

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        title: Text(
          'nav_dashboard'.tr,
          style: AppTextStyles.appBarTitle(color: kPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: adminTaskCtrl.fetchTasks,
        child: Obx(() {
          final offline = !Get.find<NetworkController>().isConnected.value;
          final filtered = adminTaskCtrl.filteredTasks;

          return CustomScrollView(
            slivers: [
              // ── App Bar ─────────────────────────────────────────
              SliverAppBar(
                backgroundColor: isDark ? kBgDark : kBgLight,
                pinned: true,
                // ── Offline banner + Week Calendar ──────────────────
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                    offline && !adminTaskCtrl.isOfflineDialogOpen.value
                        ? 125
                        : 95,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (offline && !adminTaskCtrl.isOfflineDialogOpen.value)
                        OfflineCardWidget(isDark: isDark),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                          left: 16,
                          right: 16,
                        ),
                        child: WeekCalendarWidget(
                          isDark: isDark,
                          selectedDate: adminTaskCtrl.taskSelectedDate.value,
                          onDateSelected: adminTaskCtrl.selectTaskDate,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Task Summary Chart ───────────────────────────────
              SliverPadding(
                padding: kPagePaddingHorizontal,
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                      boxShadow: [cardShadow],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: TaskLineChartWidget(isDark: isDark),
                  ),
                ),
              ),

              // ── Task count ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        'task_title'.tr,
                        style: AppTextStyles.title(color: textColor),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filtered.length}',
                          style: AppTextStyles.subTitle(color: kPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Task List ────────────────────────────────────────
              if (adminTaskCtrl.isLoading.value ||
                  (offline && filtered.isEmpty))
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverList.separated(
                    itemCount: 5,
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => TaskShimmerWidget(
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 48,
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'task_empty'.tr,
                          style: AppTextStyles.subTitle(color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final task = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskCardWidget(
                          task: task,
                          taskController: adminTaskCtrl,
                        ),
                      );
                    }, childCount: filtered.length),
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
            ],
          );
        }),
      ),
    );
  }
}
