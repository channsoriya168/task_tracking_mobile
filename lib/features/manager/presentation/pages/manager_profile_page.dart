import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';

class ManagerProfilePage extends StatelessWidget {
  const ManagerProfilePage({super.key});

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
            elevation: 0,
            pinned: true,
            actions: [
              CircularIconButton(
                icon: Icons.notifications_outlined,
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(width: 8),
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

          // ── Header ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            sliver: SliverToBoxAdapter(
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

          // ── Avatar & Name ─────────────────────────────────
          SliverPadding(
            padding: kPagePadding,
            sliver: SliverToBoxAdapter(
              child: _ProfileHeader(isDark: isDark),
            ),
          ),

          // ── Stats Row ─────────────────────────────────────
          SliverPadding(
            padding: kPageSectionPadding,
            sliver: SliverToBoxAdapter(
              child: _StatsRow(isDark: isDark),
            ),
          ),

          // ── Info Section ──────────────────────────────────
          SliverPadding(
            padding: kPageSectionLargePadding,
            sliver: SliverToBoxAdapter(
              child: Text(
                'Personal Info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: kPageSectionPadding,
            sliver: SliverToBoxAdapter(
              child: _InfoCard(isDark: isDark),
            ),
          ),

          // ── Actions ───────────────────────────────────────
          SliverPadding(
            padding: kPageSectionLargePadding,
            sliver: SliverToBoxAdapter(
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: kPageSectionPadding,
            sliver: SliverToBoxAdapter(
              child: _ActionCard(isDark: isDark),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: kContentPaddingLarge,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withAlpha(30),
                  border: Border.all(
                    color: kPrimary.withAlpha(80),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: kPrimary,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Manager Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Manager',
              style: TextStyle(
                fontSize: 12,
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'manager@company.com',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isDark});

  final bool isDark;

  static const _stats = [
    ('Tasks', 24, kPrimary),
    ('Done', 18, Color(0xFF2ED573)),
    ('Pending', 6, Color(0xFFFFA502)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: kContentPadding,
      child: Row(
        children: List.generate(_stats.length, (i) {
          final (label, count, color) = _stats[i];
          return Expanded(
            child: Column(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
                if (i < _stats.length - 1) ...[],
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.isDark});

  final bool isDark;

  static const _items = [
    (Icons.phone_rounded, 'Phone', '+855 12 345 678', Color(0xFF2ED573)),
    (Icons.work_rounded, 'Department', 'Engineering', kPrimary),
    (Icons.location_on_rounded, 'Location', 'Phnom Penh, Cambodia', Color(0xFFFFA502)),
    (Icons.calendar_today_rounded, 'Joined', 'January 2024', Color(0xFF6C63FF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_items.length, (i) {
          final (icon, label, value, color) = _items[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[600] : kTextMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < _items.length - 1)
                Divider(
                  height: 1,
                  indent: 66,
                  color: isDark
                      ? Colors.white.withAlpha(15)
                      : Colors.black.withAlpha(10),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Action Card ───────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.isDark});

  final bool isDark;

  static const _actions = [
    (Icons.lock_outline_rounded, 'Change Password', Color(0xFF6C63FF)),
    (Icons.help_outline_rounded, 'Help & Support', Color(0xFFFFA502)),
    (Icons.logout_rounded, 'Sign Out', Color(0xFFFF4757)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_actions.length, (i) {
          final (icon, label, color) = _actions[i];
          return Column(
            children: [
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: i == _actions.length - 1
                      ? const Radius.circular(16)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color == const Color(0xFFFF4757)
                                ? color
                                : (isDark ? Colors.white : kTextDark),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              if (i < _actions.length - 1)
                Divider(
                  height: 1,
                  indent: 66,
                  color: isDark
                      ? Colors.white.withAlpha(15)
                      : Colors.black.withAlpha(10),
                ),
            ],
          );
        }),
      ),
    );
  }
}
