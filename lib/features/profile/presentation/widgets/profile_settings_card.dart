import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/language_switcher_widget.dart';
import 'package:task_tracking_mobile/core/controllers/theme_controller.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade200,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Dark Mode ────────────────────────────────────────
          Obx(() {
            final dark = themeCtrl.isDark;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    dark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    size: 20,
                    color: kPrimary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'profile_dark_mode'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: themeCtrl.toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 48,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: dark ? kPrimary : Colors.grey.shade300,
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
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              dark
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_rounded,
                              size: 12,
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
            indent: 0,
            endIndent: 0,
            color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade200,
          ),

          // ── Language ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.language_rounded, size: 20, color: kPrimary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'profile_language'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : kTextDark,
                    ),
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
