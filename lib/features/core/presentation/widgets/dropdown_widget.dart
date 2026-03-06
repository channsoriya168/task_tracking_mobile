import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class DropdownWidget<T> extends StatelessWidget {
  const DropdownWidget({
    required this.value,
    required this.items,
    required this.label,
    required this.isDark,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) label;
  final bool isDark;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : kBgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? kCardDark : Colors.white,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : kTextDark,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(label(e))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
