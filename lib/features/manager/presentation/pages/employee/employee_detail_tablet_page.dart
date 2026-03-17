import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee/employee_detail_hero_header_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee/employee_detail_info_widget.dart';

class EmployeeDetailTabletPage extends StatelessWidget {
  const EmployeeDetailTabletPage({
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
              background: EmployeeDetailHeroHeaderWidget(
                employee: emp,
                accent: accent,
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmployeeDetailInfoListWidget(employee: emp, isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
