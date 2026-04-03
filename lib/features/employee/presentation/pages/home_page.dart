import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_filter_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/week_calendar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/home_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_card.dart';
import 'package:task_tracking_mobile/features/notification/presentation/widgets/notification_bell_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_empty_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'home_greeting_morning'.tr;
    if (h < 17) return 'home_greeting_afternoon'.tr;
    return 'home_greeting_evening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final authCtrl = Get.find<AuthController>();
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
                              authCtrl.profile.value?.fullName ?? '',
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
                    // ── Notification bell ──────────────────────
                    const NotificationBellWidget(),
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
              if (homeCtrl.isLoading.value) {
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
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: TaskEmptyState(isDark: isDark),
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
  final HomeController homeCtrl;

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
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ShimmerBox(
                            isDark: isDark,
                            width: double.infinity,
                            height: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ShimmerBox(isDark: isDark, width: 60, height: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ShimmerBox(isDark: isDark, width: 180, height: 12),
                    const Spacer(),
                    Row(
                      children: [
                        _ShimmerBox(isDark: isDark, width: 56, height: 20),
                        const SizedBox(width: 8),
                        _ShimmerBox(isDark: isDark, width: 56, height: 20),
                        const Spacer(),
                        _ShimmerBox(isDark: isDark, width: 36, height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
  });

  final bool isDark;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
