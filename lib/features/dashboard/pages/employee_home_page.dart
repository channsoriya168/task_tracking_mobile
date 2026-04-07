import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/dashboard/controllers/employee_home_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_task_card.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_empty_state.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'home_greeting_morning'.tr;
    if (h < 17) return 'home_greeting_afternoon'.tr;
    return 'home_greeting_evening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<EmployeeHomeController>();
    final profileCtrl = Get.find<ProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await homeCtrl.fetchTasks();
            await homeCtrl.fetchStatuses();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Greeting header ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
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
                            Obx(
                              () => Text(
                                profileCtrl.profile.value?.fullName ?? '',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark ? Colors.white : kTextDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Sticky: calendar + filter + search ────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyToolbarDelegate(
                  isDark: isDark,
                  homeCtrl: homeCtrl,
                ),
              ),

              // ── Task list / shimmer / empty ───────────────────
              Obx(() {
                if (homeCtrl.isLoading.value && homeCtrl.allTasks.isEmpty) {
                  return SliverPadding(
                    padding: kPageBottomPadding,
                    sliver: SliverList.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, __) => _TaskCardShimmer(isDark: isDark),
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
                  padding: kPageBottomPadding,
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

// ── Sticky toolbar delegate ───────────────────────────────────────────────────

class _StickyToolbarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyToolbarDelegate({required this.isDark, required this.homeCtrl});

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
  bool shouldRebuild(_StickyToolbarDelegate old) =>
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

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _TaskCardShimmer extends StatelessWidget {
  const _TaskCardShimmer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF252540) : Colors.grey.shade300;
    final highlight = isDark ? const Color(0xFF3A3A60) : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent strip ──
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // ── Content ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title + priority dot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ShimmerBox(
                              isDark: isDark,
                              width: double.infinity,
                              height: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ShimmerBox(
                            isDark: isDark,
                            width: 10,
                            height: 10,
                            radius: 5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description line 1
                      _ShimmerBox(
                        isDark: isDark,
                        width: double.infinity,
                        height: 12,
                      ),
                      const SizedBox(height: 5),
                      // Description line 2
                      _ShimmerBox(isDark: isDark, width: 180, height: 12),
                      const SizedBox(height: 10),
                      // Due date
                      _ShimmerBox(isDark: isDark, width: 100, height: 12),
                      const SizedBox(height: 14),
                      // Avatar + action button
                      Row(
                        children: [
                          _ShimmerBox(
                            isDark: isDark,
                            width: 28,
                            height: 28,
                            radius: 14,
                          ),
                          const Spacer(),
                          _ShimmerBox(
                            isDark: isDark,
                            width: 90,
                            height: 32,
                            radius: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.isDark,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final bool isDark;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
