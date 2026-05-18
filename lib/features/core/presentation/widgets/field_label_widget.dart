import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class FieldLabelWidget extends StatelessWidget {
  const FieldLabelWidget(
    this.text, {
    super.key,
    required this.isDark,
    this.isRequired = false,
  });

  final String text;
  final bool isDark;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: text.isNotEmpty
          ? TextSpan(
              text: text,
              style: AppTextStyles.formLabel(
                color: isDark ? Colors.grey[300] : kBgDark,
              ),
              children: isRequired
                  ? [
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: '*',
                        style: AppTextStyles.formLabel(color: Colors.red[400]),
                      ),
                    ]
                  : [],
            )
          : const TextSpan(),
    );
  }
}
