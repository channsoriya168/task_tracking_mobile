import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final themeCtrl = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Obx(
        () => CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: kPagePadding,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),

            // ── Profile identity ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(
                  children: [
                    // Avatar ring
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary, width: 2.5),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? kPrimary.withValues(alpha: 0.18)
                              : kPrimary.withValues(alpha: 0.1),
                        ),
                        child: const Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Name
                    Text(
                      'Alex Johnson',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      'alex@example.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : kTextMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Role pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: kPrimary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Staff Member',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Quick stats ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: kPageSectionPadding,
                child: Row(
                  children: [
                    _statTile('${ctrl.totalTasks}', 'Total', isDark),
                    const SizedBox(width: 12),
                    _statTile('${ctrl.completedTasks}', 'Done', isDark),
                    const SizedBox(width: 12),
                    _statTile('${ctrl.inReviewCount}', 'Active', isDark),
                  ],
                ),
              ),
            ),

            // ── Settings ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? kCardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Dark mode toggle
                      _settingRow(
                        icon: themeCtrl.isDark
                            ? Icons.wb_sunny_rounded
                            : Icons.nightlight_round,
                        iconColor: kPrimary,
                        title: 'Dark Mode',
                        isDark: isDark,
                        trailing: Switch(
                          value: themeCtrl.isDark,
                          onChanged: (_) => themeCtrl.toggle(),
                          activeThumbColor: kPrimary,
                        ),
                      ),
                      _divider(isDark),
                      _settingRow(
                        icon: Icons.notifications_outlined,
                        iconColor: kMediumPriority,
                        title: 'Notifications',
                        isDark: isDark,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                      ),
                      _divider(isDark),
                      _settingRow(
                        icon: Icons.lock_outline_rounded,
                        iconColor: kHighPriority,
                        title: 'Privacy',
                        isDark: isDark,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                      ),
                      _divider(isDark),
                      _settingRow(
                        icon: Icons.help_outline_rounded,
                        iconColor: kLowPriority,
                        title: 'Help & Support',
                        isDark: isDark,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sign out ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: kPageBottomPadding,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: kHighPriority.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: kHighPriority,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: kHighPriority,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String value, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: kTextMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 16,
      color: isDark ? Colors.white12 : Colors.grey.shade100,
    );
  }
}
