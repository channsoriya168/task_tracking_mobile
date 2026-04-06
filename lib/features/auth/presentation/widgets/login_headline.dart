import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

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
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : kTextDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'login_subtitle'.tr,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white54 : kTextMuted,
          ),
        ),
      ],
    );
  }
}
