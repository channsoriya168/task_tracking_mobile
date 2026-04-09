import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/offine_card_widget.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_filter_group_chips_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_header_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_list_widget.dart';

class EmployeeMobilePage extends StatelessWidget {
  const EmployeeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offline = !Get.find<NetworkController>().isConnected.value;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Stack(
        children: [
          Column(
            children: [
              EmployeeHeaderWidget(isDark: isDark, ctrl: ctrl),
              const SizedBox(height: 12),
              EmployeeFilterGroupChipsWidget(isDark: isDark, ctrl: ctrl),
              SearchBarWidget(
                isDark: isDark,
                onChanged: (v) => ctrl.searchQuery.value = v,
                hintText: 'employee_search_hint'.tr,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              ),
              // SizedBox(height: 16),
              Expanded(
                child: EmployeeListWidget(isDark: isDark, ctrl: ctrl),
              ),
            ],
          ),
          if (offline) OfflineCardWidget(isDark: isDark),
        ],
      ),
      floatingActionButton: Get.find<AuthController>().role == UserRole.employee
          ? null
          : FloatingActionButton(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              onPressed: () =>
                  Get.find<EmployeeController>().showCreateDialog(),
              child: const Icon(Icons.person_add_rounded),
            ),
    );
  }
}
