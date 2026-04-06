import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : kTextDark,
              ),
              children: isRequired
                  ? [
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[400],
                        ),
                      ),
                    ]
                  : [],
            )
          : const TextSpan(),
    );
  }
}
