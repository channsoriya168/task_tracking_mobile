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
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      body: FutureBuilder<Employee>(
        key: ValueKey(_refreshKey),
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
                    onPressed: Get.back,
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }

          _employee = snapshot.data!;
          final employee = _employee!;
          final accent = employee.taskGroups.isNotEmpty
              ? employee.taskGroups.first.groupColor
              : kPrimary;

          return CustomScrollView(
            slivers: [
              // ── Hero header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 290,
                pinned: true,
                backgroundColor: accent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: EmployeeDetailHeaderContent(
                    employee: employee,
                    accent: accent,
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      EmployeeDetailStats(employee: employee, isDark: isDark),
                      const SizedBox(height: 20),

                      // Edit + Delete buttons
                      EmployeeDetailActions(
                        isDark: isDark,
                        onEdit: () async {
                          await Get.find<AdminEmployeeFormController>()
                              .showEditDialog(employee);
                          _refresh();
                        },
                        onDelete: () async {
                          final confirmed = await showConfirmDeleteDialog(
                            context,
                            title: 'Delete Employee',
                            content:
                                'Are you sure you want to delete this employee?',
                          );
                          if (confirmed == true) {
                            final deleted = await Get.find<
                                    AdminEmployeeController>()
                                .deleteEmployee(widget.employeeId);
                            if (deleted) Get.back();
                          }
                        },
                      ),
                      const SizedBox(height: 28),

                      // Info list
                      EmployeeDetailInfoList(
                        employee: employee,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
