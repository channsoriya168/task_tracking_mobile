import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class GroupChipWidget extends StatelessWidget {
  const GroupChipWidget({required this.name, required this.isDark});
  final String name;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? Colors.white.withAlpha(14) : kPrimary.withAlpha(18);
    final border = isDark ? Colors.white.withAlpha(28) : kPrimary.withAlpha(55);
    final textColor = isDark
        ? Colors.white.withAlpha(180)
        : const Color(0xFF4B47CC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
