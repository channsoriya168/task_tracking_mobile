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
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white38 : kTextMuted,
        letterSpacing: kLs(1.2),
      ),
    );
  }
}
