import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/presentation/controllers/theme_controller.dart';

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

            // ── Profile card ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: kPageSectionLargePadding,
                child: Container(
                  padding: kContentPaddingLarge,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, Color(0xFF9B8FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alex Johnson',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'alex@example.com',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                          activeColor: kPrimary,
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
                      color: kHighPriority.withOpacity(0.1),
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
              color: iconColor.withOpacity(0.12),
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
