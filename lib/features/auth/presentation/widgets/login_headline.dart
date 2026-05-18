import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class LoginHeadline extends StatelessWidget {
  const LoginHeadline({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'login_welcome'.tr,
          style: AppTextStyles.loginTitle(
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'login_subtitle'.tr,
          style: AppTextStyles.loginSubtitle(
            color: isDark ? Colors.white54 : kTextMuted,
          ),
        ),
      ],
    );
  }
}
