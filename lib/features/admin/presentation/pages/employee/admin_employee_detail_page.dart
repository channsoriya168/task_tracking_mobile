import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employee_by_id_usecase.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_employee_detail_widgets.dart';

class AdminEmployeeDetailPage extends StatelessWidget {
  final String employeeId;

  const AdminEmployeeDetailPage({super.key, required this.employeeId});

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
      ),
      body: FutureBuilder<Employee>(
        future: FetchEmployeeByIdUsecase(
          Get.find<EmployeeRepository>(),
        ).call(employeeId),
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

          final employee = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              children: [
                EmployeeDetailHeader(employee: employee, isDark: isDark),
                const SizedBox(height: 16),
                EmployeeDetailInfoCard(
                  employee: employee,
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
