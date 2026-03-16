import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_detail_widgets.dart';

class EmployeeDetailTabletPage extends StatelessWidget {
  const EmployeeDetailTabletPage({
    super.key,
    required this.emp,
    required this.ctrl,
    required this.isDark,
    required this.onRefresh,
  });

  final Employee emp;
  final EmployeeController ctrl;
  final bool isDark;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final accent =
        emp.taskGroups.isNotEmpty ? emp.taskGroups.first.groupColor : kPrimary;
    final tasks = ctrl.tasksForEmployee(emp.id);

    return Scaffold(
      backgroundColor: isDark ? kBgDark : const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
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
              background: EmployeeDetailHeroHeader(employee: emp, accent: accent),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: stats + actions + info ─────────────
                  SizedBox(
                    width: 380,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EmployeeDetailStats(employee: emp, isDark: isDark),
                        const SizedBox(height: 20),
                        EmployeeDetailActions(
                          isDark: isDark,
                          onEdit: () async {
                            await Get.find<EmployeeController>()
                                .showEditDialog(emp);
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
                        EmployeeDetailInfoList(employee: emp, isDark: isDark),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: isDark
                        ? Colors.white.withAlpha(12)
                        : Colors.black.withAlpha(8),
                  ),
                  const SizedBox(width: 24),

                  // ── Right: tasks ──────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            EmployeeDetailSectionLabel(
                              label: 'Assigned Tasks',
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimary.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        EmployeeTasksSection(tasks: tasks, isDark: isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}