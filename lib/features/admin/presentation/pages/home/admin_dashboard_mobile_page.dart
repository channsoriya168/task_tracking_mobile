import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';

class AdminDashboardMobilePage extends StatelessWidget {
  const AdminDashboardMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? kBgDark : kBgLight,
      child: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────
          SliverAppBar(
            backgroundColor: isDark ? kBgDark : kBgLight,
            actions: [
              Obx(
                () => CircularIconButton(
                  icon: themeCtrl.isDark
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  isDark: isDark,
                  onTap: themeCtrl.toggle,
                ),
              ),
              Padding(
                padding: kPagePaddingHorizontal,
                child: CircularIconButton(
                  icon: Icons.settings_outlined,
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
            ],
          ),

          // ── Greeting ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overview of your team and tasks',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Summary Grid (2 columns) ───────────────────────
          SliverPadding(
            padding: kPagePadding,
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _SummaryCard(
                  isDark: isDark,
                  label: _kStats[i].$1,
                  count: _kStats[i].$2,
                  icon: _kStats[i].$3,
                  color: _kStats[i].$4,
                ),
                childCount: _kStats.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.6,
              ),
            ),
          ),

          // ── Recent Activity Header ────────────────────────
          SliverPadding(
            padding: kPageSectionLargePadding,
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      color: kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Activity List ─────────────────────────────────
          SliverPadding(
            padding: kPageSectionPadding,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: kItemSpacing,
                  child: _ActivityCard(isDark: isDark, index: i),
                ),
                childCount: _kActivity.length,
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

// ── Shared Data ───────────────────────────────────────────────

const _kStats = [
  ('Total Tasks', 48, Icons.grid_view_rounded, kPrimary),
  ('Staff Members', 12, Icons.people_rounded, Color(0xFF2ED573)),
  ('Completed', 32, Icons.check_circle_outline_rounded, Color(0xFF6C63FF)),
  ('In Progress', 8, Icons.sync_rounded, Color(0xFFFFA502)),
];

const _kActivity = [
  (
    'Task assigned to John',
    'Engineering',
    '2 min ago',
    Icons.assignment_rounded,
    kPrimary,
  ),
  (
    'Jane completed Design task',
    'Design',
    '15 min ago',
    Icons.check_circle_rounded,
    Color(0xFF2ED573),
  ),
  (
    'New staff member added',
    'HR',
    '1 hr ago',
    Icons.person_add_rounded,
    Color(0xFFFFA502),
  ),
  (
    'Task overdue: API Integration',
    'Engineering',
    '2 hr ago',
    Icons.warning_rounded,
    Color(0xFFFF4757),
  ),
  (
    'Report generated',
    'Management',
    '5 hr ago',
    Icons.bar_chart_rounded,
    Color(0xFF6C63FF),
  ),
  (
    'Meeting scheduled',
    'Management',
    'Yesterday',
    Icons.event_rounded,
    Color(0xFFFFA502),
  ),
];

// ── Summary Card ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.isDark,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final bool isDark;
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: kContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Activity Card ─────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.isDark, required this.index});

  final bool isDark;
  final int index;

  @override
  Widget build(BuildContext context) {
    final (title, tag, time, icon, color) = _kActivity[index];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: kTextMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
