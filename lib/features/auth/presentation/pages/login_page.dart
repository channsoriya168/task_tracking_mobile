import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/staff/data/models/user_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _roles = [
    _RoleConfig(
      role: UserRole.manager,
      label: 'Manager',
      subtitle: 'Manage tasks & team',
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFF6C63FF),
    ),
    _RoleConfig(
      role: UserRole.admin,
      label: 'Admin',
      subtitle: 'View progress & analytics',
      icon: Icons.analytics_rounded,
      color: Color(0xFFFFA502),
    ),
    _RoleConfig(
      role: UserRole.staff,
      label: 'Staff',
      subtitle: 'Accept & complete tasks',
      icon: Icons.work_rounded,
      color: Color(0xFF2ED573),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: SafeArea(
        child: Padding(
          padding: kPagePaddingWithBottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: kPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to\nTaskFlow',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : kTextDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your role to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white54 : kTextMuted,
                ),
              ),
              const SizedBox(height: 48),
              ..._roles.map(
                (r) => _RoleCard(
                  config: r,
                  isDark: isDark,
                  onTap: () => r.role == UserRole.staff
                      ? _showStaffPicker(context, auth, isDark)
                      : auth.login(
                          kSampleUsers.firstWhere((u) => u.role == r.role),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStaffPicker(
    BuildContext context,
    AuthController auth,
    bool isDark,
  ) {
    final staffUsers = kSampleUsers
        .where((u) => u.role == UserRole.staff)
        .toList();
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Staff Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            ...staffUsers.map(
              (user) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2ED573).withOpacity(0.15),
                  child: Text(
                    user.avatarLetter,
                    style: const TextStyle(
                      color: Color(0xFF2ED573),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                subtitle: Text(
                  user.email,
                  style: const TextStyle(color: kTextMuted, fontSize: 12),
                ),
                onTap: () {
                  Get.back();
                  auth.login(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Config ──────────────────────────────────────────────────
class _RoleConfig {
  final UserRole role;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _RoleConfig({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

// ── Role Card ────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.config,
    required this.isDark,
    required this.onTap,
  });

  final _RoleConfig config;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: config.color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: config.color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(config.icon, color: config.color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    config.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.white30 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
