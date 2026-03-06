import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_employee_detail_widgets.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';

class AdminEmployeeDetailPage extends StatelessWidget {
  final Employee employee;
  final Position? position;

  const AdminEmployeeDetailPage({
    super.key,
    required this.employee,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE5E7EB);
    final cardBg = isDark ? kCardDark : Colors.white;

    final taskCtrl = Get.find<AdminTaskController>();
    final assignedTasks = taskCtrl.tasks
        .where((t) => t.acceptedBy == employee.name)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
        ),
        leadingWidth: 60,
        title: Text(
          'Staff Detail',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : kTextMuted,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            EmployeeDetailHeader(
              employee: employee,
              position: position,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            EmployeeDetailInfoCard(
              employee: employee,
              isDark: isDark,
              borderColor: borderColor,
              cardBg: cardBg,
            ),
            const SizedBox(height: 12),
            EmployeeAssignedTasksCard(
              tasks: assignedTasks,
              isDark: isDark,
              borderColor: borderColor,
              cardBg: cardBg,
            ),
          ],
        ),
      ),
    );
  }
}
