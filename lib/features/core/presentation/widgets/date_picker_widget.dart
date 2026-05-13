import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class DatePickerWidget extends StatelessWidget {
  const DatePickerWidget({
    required this.isDark,
    required this.value,
    required this.onPicked,
    required this.label,
    this.isRequired = false,
    this.errorText,
  });

  final bool isDark;
  final Rx<DateTime?> value;
  final ValueChanged<DateTime> onPicked;
  final String label;
  final bool isRequired;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.formLabel(
              color: isDark ? Colors.white : kTextDark,
            ),
            children: [
              TextSpan(text: 'profile_date_of_birth'.tr),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final date = value.value;
          final hasError = errorText != null && errorText!.isNotEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) onPicked(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? kSurfaceDark : kBgLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasError
                          ? Colors.red
                          : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      width: hasError ? 1.5 : 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        date != null
                            ? '${date.day.toString().padLeft(2, '0')}/'
                                  '${date.month.toString().padLeft(2, '0')}/'
                                  '${date.year}'
                            : label,
                        style: TextStyle(
                          fontSize: 14,
                          color: date != null
                              ? (isDark ? Colors.white : kTextDark)
                              : (isDark ? Colors.grey[600] : Colors.grey[400]),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}
