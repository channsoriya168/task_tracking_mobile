import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';

class EmployeeFilterGroupChipsWidget extends StatelessWidget {
  const EmployeeFilterGroupChipsWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = ctrl.taskGroups.toList();
      final selected = ctrl.selectedTaskGroupId.value;

      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // ── "All" chip ──────────────────────────────────
            _FilterChip(
              label: 'All',
              isSelected: selected.isEmpty,
              color: kPrimary,
              isDark: isDark,
              icon: Icons.people_rounded,
              onTap: () => ctrl.selectedTaskGroupId.value = '',
            ),

            // ── Group chips ─────────────────────────────────
            ...groups.map(
              (g) => _FilterChip(
                label: g.name,
                isSelected: selected == g.id,
                color: g.color ?? kPrimary,
                isDark: isDark,
                onTap: () => ctrl.selectedTaskGroupId.value = g.id,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? kCardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? Colors.white.withAlpha(18)
                    : Colors.grey.withAlpha(40)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(70),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : kTextMuted),
              ),
              const SizedBox(width: 5),
            ] else ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[300] : kTextDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
