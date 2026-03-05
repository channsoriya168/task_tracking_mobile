import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class DatePickerWidget extends StatelessWidget {
  const DatePickerWidget({
    required this.isDark,
    required this.value,
    required this.onPicked,
    required this.label,
  });

  final bool isDark;
  final Rx<DateTime?> value;
  final ValueChanged<DateTime> onPicked;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : kTextMuted,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final date = value.value;
          return GestureDetector(
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? kSurfaceDark : kBgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cake_outlined,
                    size: 18,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                  const SizedBox(width: 10),
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
          );
        }),
      ],
    );
  }
}
