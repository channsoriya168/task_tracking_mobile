import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/data/models/employee.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/employee_dialogs.dart';

class AdminPositionPage extends StatelessWidget {
  const AdminPositionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : kTextDark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Positions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ),
      body: Obx(() {
        final positions = ctrl.positions;
        if (positions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 60,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No positions yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first position',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: positions.length,
          itemBuilder: (_, i) {
            final pos = positions[i];
            final count = ctrl.employeeCountByPosition(pos.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PositionCard(
                isDark: isDark,
                ctrl: ctrl,
                position: pos,
                employeeCount: count,
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => showPositionDialog(context, ctrl, isDark),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ── Position Card ─────────────────────────────────────────────
class _PositionCard extends StatelessWidget {
  const _PositionCard({
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
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 40 : 10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: position.color.withAlpha(35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.work_rounded,
                  color: position.color,
                  size: 22,
                ),
              ),
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
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: position.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.edit_rounded,
                size: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
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