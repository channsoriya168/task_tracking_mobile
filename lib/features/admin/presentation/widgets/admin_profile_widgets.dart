import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

// ── Profile header card ──────────────────────────────────────────

class AdminProfileHeader extends StatelessWidget {
  const AdminProfileHeader({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPageSectionLargePadding,
      child: Container(
        padding: kContentPaddingLarge,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF6C63FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
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
                        'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'admin@company.com',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoPill(
              icon: Icons.business_outlined,
              label: 'Operations',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Team & task stats ────────────────────────────────────────────

class AdminProfileStats extends StatelessWidget {
  const AdminProfileStats({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final taskCtrl = Get.find<AdminTaskController>();
    final empCtrl = Get.find<AdminEmployeeController>();

    return Padding(
      padding: kPageSectionPadding,
      child: Obx(() {
        final tasks = taskCtrl.tasks;
        final total = tasks.length;
        final done =
            tasks.where((t) => t.status == TaskStatus.done).length;
        final inProgress =
            tasks.where((t) => t.status == TaskStatus.inProgress).length;
        final members = empCtrl.employees.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AdminStatTile(
                  value: '$total',
                  label: 'Total Tasks',
                  icon: Icons.task_alt_rounded,
                  color: kPrimary,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                AdminStatTile(
                  value: '$done',
                  label: 'Completed',
                  icon: Icons.check_circle_outline_rounded,
                  color: kLowPriority,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                AdminStatTile(
                  value: '$inProgress',
                  label: 'In Progress',
                  icon: Icons.pending_outlined,
                  color: kMediumPriority,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                AdminStatTile(
                  value: '$members',
                  label: 'Team Members',
                  icon: Icons.group_outlined,
                  color: const Color(0xFF1976D2),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class AdminStatTile extends StatelessWidget {
  const AdminStatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings section ─────────────────────────────────────────────

class AdminProfileSettings extends StatelessWidget {
  const AdminProfileSettings({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? kCardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Obx(
                  () => AdminSettingRow(
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
                ),
                AdminSettingDivider(isDark: isDark),
                AdminSettingRow(
                  icon: Icons.notifications_outlined,
                  iconColor: kMediumPriority,
                  title: 'Notifications',
                  isDark: isDark,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                ),
                AdminSettingDivider(isDark: isDark),
                AdminSettingRow(
                  icon: Icons.lock_outline_rounded,
                  iconColor: kHighPriority,
                  title: 'Privacy',
                  isDark: isDark,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                ),
                AdminSettingDivider(isDark: isDark),
                AdminSettingRow(
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
        ],
      ),
    );
  }
}

class AdminSettingRow extends StatelessWidget {
  const AdminSettingRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDark;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
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
}

class AdminSettingDivider extends StatelessWidget {
  const AdminSettingDivider({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 16,
      color: isDark ? Colors.white12 : Colors.grey.shade100,
    );
  }
}

// ── Sign out button ──────────────────────────────────────────────

class AdminProfileSignOut extends StatelessWidget {
  const AdminProfileSignOut({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPageBottomPadding,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: kHighPriority.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: kHighPriority, size: 18),
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
    );
  }
}
