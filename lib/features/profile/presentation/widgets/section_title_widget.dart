import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class SectionTitleWidget extends StatelessWidget {
  const SectionTitleWidget({
    super.key,
    required this.label,
    required this.isDark,
  });
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : kTextDark,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
