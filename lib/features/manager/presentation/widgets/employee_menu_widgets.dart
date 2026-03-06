import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee_menu_item.dart';
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
        EmployeeAvatar(
          name: emp.name,
          color: accentColor,
          radius: 24,
          imagePath: emp.imagePath,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emp.name,
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
        if (emp.hasQr) EmployeeMenuQrBadge(isExpired: emp.isQrExpired),
      ],
    );
  }
}

// ── QR Status Badge ────────────────────────────────────────────
class EmployeeMenuQrBadge extends StatelessWidget {
  const EmployeeMenuQrBadge({super.key, required this.isExpired});

  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final color = isExpired ? kHighPriority : kLowPriority;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isExpired ? 'QR Expired' : 'QR Active',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}