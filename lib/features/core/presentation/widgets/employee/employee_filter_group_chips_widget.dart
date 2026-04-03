import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/themes/app_text_styles.dart';
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
      final groups = ctrl.Groups.toList();
      final selected = ctrl.selectedTaskGroupId.value;

      return Padding(
        padding: kPagePaddingHorizontal,
        child: SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // ── "All" chip ──────────────────────────────────
              _FilterChip(
                label: 'employee_all'.tr,
                isSelected: selected.isEmpty,
                isDark: isDark,
                icon: Icons.people_rounded,
                onTap: () => ctrl.selectedTaskGroupId.value = '',
              ),

              // ── Group chips ─────────────────────────────────
              ...groups.map(
                (g) => _FilterChip(
                  label: g.name,
                  isSelected: selected == g.id,

                  isDark: isDark,
                  onTap: () => ctrl.selectedTaskGroupId.value = g.id,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
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
          color: isSelected ? kPrimary : (isDark ? kCardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? kPrimary
                : (isDark
                      ? Colors.white.withAlpha(18)
                      : Colors.grey.withAlpha(40)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimary.withAlpha(70),
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
            ],
            Text(
              label,
              style: AppTextStyles.chipLabel(
                selected: isSelected,
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
