import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class LoginHeadline extends StatelessWidget {
  const LoginHeadline({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : kTextDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your phone number to continue',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white54 : kTextMuted,
          ),
        ),
      ],
    );
  }
}
