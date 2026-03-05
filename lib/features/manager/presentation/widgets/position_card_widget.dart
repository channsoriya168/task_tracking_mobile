// ── Position Card ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/action_button.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_dialogs.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';

class PositionCardWidget extends StatelessWidget {
  const PositionCardWidget({
    required this.isDark,
    required this.ctrl,
    required this.position,
    required this.employeeCount,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Position position;
  final int employeeCount;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(position.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ctrl.deletePosition(position.id),
      child: GestureDetector(
        onTap: () => showPositionDialog(context, ctrl, isDark, position),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? kBgDark : kBgLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: position.color.withAlpha(100),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$employeeCount ${employeeCount == 1 ? 'member' : 'members'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              ActionButton(
                icon: Icons.edit_rounded,
                color: position.color,
                onTap: () =>
                    showPositionDialog(context, ctrl, isDark, position),
              ),
              const SizedBox(width: 6),
              ActionButton(
                icon: Icons.delete_rounded,
                color: kHighPriority,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    final hasMembers = employeeCount > 0;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Position'),
        content: Text(
          hasMembers
              ? 'This will also remove $employeeCount ${employeeCount == 1 ? 'employee' : 'employees'} in "${position.name}". Continue?'
              : 'Delete position "${position.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: kHighPriority),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
