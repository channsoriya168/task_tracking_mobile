import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/app/widgets/language_switcher_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_card.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return ProfileCard(
      isDark: isDark,
      child: Column(
        children: [
          // ── Dark Mode row ────────────────────────────────────
          Obx(() {
            final dark = themeCtrl.isDark;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _SettingIcon(
                    icon: dark
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_dark_mode'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : kTextDark,
                          ),
                        ),
                        Text(
                          dark ? 'Dark' : 'Light',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Custom animated toggle
                  GestureDetector(
                    onTap: themeCtrl.toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 50,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: dark ? kPrimary : Colors.grey.shade300,
                        boxShadow: [
                          BoxShadow(
                            color: dark
                                ? kPrimary.withAlpha(60)
                                : Colors.black.withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: dark
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              dark
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_rounded,
                              size: 13,
                              color: dark ? kPrimary : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),

          // ── Language row ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _SettingIcon(icon: Icons.language_rounded, isDark: isDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'profile_language'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                      Text(
                        'English / ខ្មែរ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                LanguageSwitcherSegment(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular icon container for settings rows.
class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, required this.isDark});
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: kPrimary.withAlpha(isDark ? 35 : 20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: kPrimary, size: 18),
    );
  }
}
