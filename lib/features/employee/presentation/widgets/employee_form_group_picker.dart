import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/group_bottom_sheet.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';

class EmployeeFormGroupPicker extends StatelessWidget {
  const EmployeeFormGroupPicker({
    super.key,
    required this.controller,
    required this.isDark,
  });

  final EmployeeController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tgCtrl = Get.find<GroupController>();
    return Obx(() {
      final groups = tgCtrl.groups.cast<Group>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'task_group'.tr,
                    style: AppTextStyles.formLabel(
                      color: isDark ? Colors.white : kTextDark,
                    ),
                    children: [
                      TextSpan(
                        text: ' *',
                        style: AppTextStyles.formLabel(color: Colors.red[400]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  tgCtrl.initGroupForm(null);
                  Get.bottomSheet(
                    const GroupBottomSheet(),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 15, color: kPrimary),
                    const SizedBox(width: 3),
                    Text(
                      'new'.tr,
                      style: AppTextStyles.formLabel(color: kPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            GestureDetector(
              onTap: () => Get.bottomSheet(
                const GroupBottomSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimary.withAlpha(80), width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work_outline_rounded, size: 18, color: kPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No task groups yet. Tap here to create one first.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : kTextMuted,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: kPrimary,
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groups.map((g) {
                final selected = controller.selectedGroupId.value == g.id;
                final color = g.color ?? kPrimary;
                return GestureDetector(
                  onTap: () => controller.selectGroup(g.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? color : color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? color : color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          g.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      );
    });
  }
}
