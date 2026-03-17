import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee_menu_item.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

// ── Sheet Handle ───────────────────────────────────────────────
class EmployeeMenuHandle extends StatelessWidget {
  const EmployeeMenuHandle({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Employee Summary ───────────────────────────────────────────
class EmployeeMenuSummary extends StatelessWidget {
  const EmployeeMenuSummary({
    super.key,
    required this.emp,
    required this.accentColor,
    required this.isDark,
  });

  final Employee emp;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EmployeeAvatarWidget(
          name: emp.fullName,
          color: accentColor,
          radius: 24,
          imagePath: emp.profileImageUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emp.fullName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              Text(
                emp.email,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Menu Item Tile ─────────────────────────────────────────────
class EmployeeMenuItemTile extends StatelessWidget {
  const EmployeeMenuItemTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  final EmployeeMenuItem item;
  final bool isDark;
  final VoidCallback onTap;

  Color _resolveColor() {
    if (item.isDanger) return kHighPriority;
    if (item.isWarning) return kMediumPriority;
    if (item.isPrimary) return kPrimary;
    return isDark ? Colors.white : kTextDark;
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: color.withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }
}
