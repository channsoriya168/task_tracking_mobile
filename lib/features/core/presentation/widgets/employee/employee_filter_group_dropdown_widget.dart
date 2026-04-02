import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';

class EmployeeFilterTaskGroupDropdownWidget extends StatelessWidget {
  const EmployeeFilterTaskGroupDropdownWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Obx(() {
        final groups = ctrl.taskGroups.toList();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: ctrl.selectedTaskGroupId.value,
              dropdownColor: isDark ? kCardDark : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.grey[500] : kTextMuted,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : kTextDark,
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 18,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'All Group',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                ...groups.map(
                  (g) => DropdownMenuItem(
                    value: g.id,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: g.color ?? kPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(g.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) => ctrl.selectedTaskGroupId.value = val ?? '',
            ),
          ),
        );
      }),
    );
  }
}
