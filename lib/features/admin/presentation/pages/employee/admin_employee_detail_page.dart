import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employee_by_id_usecase.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_form_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_employee_detail_widgets.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';

class AdminEmployeeDetailPage extends StatefulWidget {
  final String employeeId;

  const AdminEmployeeDetailPage({super.key, required this.employeeId});

  @override
  State<AdminEmployeeDetailPage> createState() =>
      _AdminEmployeeDetailPageState();
}

class _AdminEmployeeDetailPageState extends State<AdminEmployeeDetailPage> {
  Employee? _employee;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE5E7EB);
    final cardBg = isDark ? kCardDark : Colors.white;

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
        actions: [
          _DetailActionButton(
            icon: Icons.edit_rounded,
            color: kMediumPriority,
            isDark: isDark,
            borderColor: borderColor,
            cardBg: cardBg,
            onTap: () async {
              if (_employee == null) return;
              Get.find<AdminEmployeeFormController>()
                  .showEditDialog(_employee!);
            },
          ),
          const SizedBox(width: 8),
          _DetailActionButton(
            icon: Icons.delete_rounded,
            color: kHighPriority,
            isDark: isDark,
            borderColor: borderColor,
            cardBg: cardBg,
            onTap: () async {
              final confirmed = await showConfirmDeleteDialog(
                context,
                title: 'Delete Employee',
                content: 'Are you sure you want to delete this employee?',
              );
              if (confirmed == true) {
                final deleted = await Get.find<AdminEmployeeController>()
                    .deleteEmployee(widget.employeeId);
                if (deleted) Get.back();
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<Employee>(
        future: FetchEmployeeByIdUsecase(
          Get.find<EmployeeRepository>(),
        ).call(widget.employeeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load employee.',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : kTextMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }

          _employee = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              children: [
                EmployeeDetailHeader(employee: _employee!, isDark: isDark),
                const SizedBox(height: 16),
                EmployeeDetailInfoCard(
                  employee: _employee!,
                  isDark: isDark,
                  borderColor: borderColor,
                  cardBg: cardBg,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
    required this.icon,
    required this.color,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
