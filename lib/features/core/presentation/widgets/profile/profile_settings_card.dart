import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
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
      child: Obx(
        () {
          final dark = themeCtrl.isDark;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  dark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: kPrimary,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                ),
                Switch(
                  value: themeCtrl.isDark,
                  onChanged: (_) => themeCtrl.toggle(),
                  activeThumbColor: kPrimary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
