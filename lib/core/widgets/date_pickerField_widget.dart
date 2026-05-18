import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class DatePickerFieldWidget extends StatelessWidget {
  const DatePickerFieldWidget({
    required this.isDark,
    required this.value,
    required this.hint,
    required this.firstDate,
    required this.onPick,
    required this.onClear,
  });

  final bool isDark;
  final DateTime? value;
  final String hint;
  final DateTime firstDate;
  final ValueChanged<DateTime> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final initial = value ?? now;
        final picked = await showDatePicker(
          context: ctx,
          initialDate: initial.isBefore(firstDate) ? firstDate : initial,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 730)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: kPrimary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : kBgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: isDark ? Colors.grey[500] : kTextMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null ? hint : formatDate(value!),
                style: TextStyle(
                  fontSize: 13,
                  color: value == null
                      ? (isDark ? Colors.grey[600] : Colors.grey[400])
                      : (isDark ? Colors.white : kTextDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
