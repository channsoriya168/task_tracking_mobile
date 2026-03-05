import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_list_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/manager_position_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

class ManagerEmployeeMobilePage extends StatelessWidget {
  const ManagerEmployeeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        children: [
          _Header(isDark: isDark, ctrl: ctrl),
          EmployeeSearchBar(
            isDark: isDark,
            ctrl: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          ),
          Expanded(
            child: EmployeeListWidget(isDark: isDark, ctrl: ctrl),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => ctrl.showDialog(isDark),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.isDark, required this.ctrl});

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employees',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              Obx(
                () => Text(
                  '${ctrl.employees.length} members',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => Get.to(() => const ManagerPositionPage()),
            icon: const Icon(Icons.work_outline_rounded, size: 16),
            label: const Text('Positions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
