import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_header_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_list_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

class ManagerEmployeeMobilePage extends StatelessWidget {
  const ManagerEmployeeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        children: [
          EmployeeHeaderWidget(isDark: isDark, ctrl: ctrl),
          _TaskGroupDropdown(isDark: isDark, ctrl: ctrl),
          EmployeeSearchBar(
            isDark: isDark,
            ctrl: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          ),
          Expanded(
            child: EmployeeListWidget(isDark: isDark, ctrl: ctrl),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => ctrl.showDialog(isDark),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}

// ── Task Group Dropdown ────────────────────────────────────────
class _TaskGroupDropdown extends StatelessWidget {
  const _TaskGroupDropdown({required this.isDark, required this.ctrl});

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
                        'All Task Groups',
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
              onChanged: (val) =>
                  ctrl.selectedTaskGroupId.value = val ?? '',
            ),
          ),
        );
      }),
    );
  }
}
