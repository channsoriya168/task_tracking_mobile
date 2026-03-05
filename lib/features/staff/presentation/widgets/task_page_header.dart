import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';

class TaskPageHeader extends StatelessWidget {
  const TaskPageHeader({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Padding(
      padding: kPagePadding,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.space_dashboard_rounded,
              color: kPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Task List',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const Spacer(),
          CircularIconButton(
            icon: Icons.reply_rounded,
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
        ],
      ),
    );
  }
}
