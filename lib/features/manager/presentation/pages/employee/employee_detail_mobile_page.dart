import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_detail_widgets.dart';

class EmployeeDetailMobilePage extends StatelessWidget {
  const EmployeeDetailMobilePage({
    super.key,
    required this.emp,
    required this.ctrl,
    required this.isDark,
    required this.onRefresh,
    this.viewOnly = false,
  });

  final Employee emp;
  final EmployeeController ctrl;
  final bool isDark;
  final VoidCallback onRefresh;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    final accent = emp.taskGroups.isNotEmpty
        ? emp.taskGroups.first.groupColor
        : kPrimary;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──────────────────────────────────────
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
              background: EmployeeDetailHeroHeader(
                employee: emp,
                accent: accent,
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Edit + Delete (hidden in view-only mode)
                  if (!viewOnly) ...[
                    EmployeeDetailActions(
                      isDark: isDark,
                      onEdit: () async {
                        await Get.find<EmployeeController>().showEditDialog(
                          emp,
                        );
                        onRefresh();
                      },
                      onDelete: () async {
                        final confirmed = await showConfirmDeleteDialog(
                          context,
                          title: 'Delete Employee',
                          content:
                              'Are you sure you want to delete this employee?',
                        );
                        if (confirmed == true) {
                          await ctrl.deleteEmployee(emp.id);
                          Get.back();
                        }
                      },
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Info list
                  EmployeeDetailInfoList(employee: emp, isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
