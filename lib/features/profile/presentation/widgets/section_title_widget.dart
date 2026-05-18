import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';

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
    return Text(label, style: AppTextStyles.title());
  }
}
