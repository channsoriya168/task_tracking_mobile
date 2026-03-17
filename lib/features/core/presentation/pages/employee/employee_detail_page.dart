import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_employee_by_id_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/pages/employee/employee_detail_mobile_page.dart';
import 'package:task_tracking_mobile/features/core/presentation/pages/employee/employee_detail_tablet_page.dart';

class EmployeeDetailPage extends StatefulWidget {
  const EmployeeDetailPage({
    super.key,
    required this.employeeId,
    this.viewOnly = false,
  });

  final String employeeId;
  final bool viewOnly;

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Employee>(
      key: ValueKey(_refreshKey),
      future: FetchEmployeeByIdUsecase(
        Get.find<EmployeeRepository>(),
      ).call(widget.employeeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load employee.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: Get.back,
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }

        final emp = snapshot.data!;

        if (Responsive.isMobile(context)) {
          return EmployeeDetailMobilePage(
            emp: emp,
            ctrl: ctrl,
            isDark: isDark,
            onRefresh: _refresh,
            viewOnly: widget.viewOnly,
          );
        }
        return EmployeeDetailTabletPage(
          emp: emp,
          ctrl: ctrl,
          isDark: isDark,
          onRefresh: _refresh,
          viewOnly: widget.viewOnly,
        );
      },
    );
  }
}