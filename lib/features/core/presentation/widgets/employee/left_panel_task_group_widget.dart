// ── Left Panel ─────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_group/task_group_title_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_group/task_group_dialog.dart';

class LeftPanelTaskGroupWidget extends StatelessWidget {
  const LeftPanelTaskGroupWidget({
    required this.isDark,
    required this.ctrl,
    required this.posCtrl,
    required this.selectedId,
    required this.onSelect,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final TaskGroupController posCtrl;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? kSurfaceDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 4),
            child: Row(
              children: [
                Text(
                  'Task Groups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      showTaskGroupDialog(context, posCtrl, isDark),
                  icon: Icon(Icons.add_rounded, color: kPrimary, size: 22),
                  tooltip: 'Add Task Group',
                ),
              ],
            ),
          ),

          // "All" option
          Obx(() {
            final totalCount = ctrl.employees.length;
            return TaskGroupTitleWidget(
              isDark: isDark,
              label: 'All Employees',
              count: totalCount,
              color: kPrimary,
              icon: Icons.people_rounded,
              selected: selectedId == null,
              onTap: () => onSelect(null),
            );
          }),

          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'GROUPS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Position list
          Expanded(
            child: Obx(() {
              final positions = ctrl.taskGroups;
              if (positions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No task groups yet.\nTap + to create one.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[600] : kTextMuted,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: positions.length,
                itemBuilder: (_, i) {
                  final pos = positions[i];
                  final count = posCtrl.employeeCountByTaskGroup(pos.id);
                  return TaskGroupTitleWidget(
                    isDark: isDark,
                    label: pos.name,
                    count: count,
                    color: pos.color ?? kPrimary,
                    icon: Icons.work_rounded,
                    selected: selectedId == pos.id,
                    onTap: () => onSelect(pos.id),
                    onEdit: () =>
                        showTaskGroupDialog(context, posCtrl, isDark, pos),
                    onDelete: () async {
                      final confirmed = await _confirmDelete(
                        context,
                        pos,
                        count,
                      );
                      if (confirmed == true) {
                        if (selectedId == pos.id) onSelect(null);
                        posCtrl.deleteTaskGroup(pos.id);
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, TaskGroup pos, int count) {
    return showConfirmDeleteDialog(
      context,
      title: 'Delete Task Group',
      content: count > 0
          ? 'This removes $count ${count == 1 ? 'employee' : 'employees'} in "${pos.name}". Continue?'
          : 'Delete task group "${pos.name}"?',
    );
  }
}
