import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/core/widgets/offline_card_widget.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/search_bar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_bottom_sheet.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_filter_group_chips_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_list_widget.dart';
import 'package:task_tracking_mobile/features/group/presentation/pages/group_page.dart';

class EmployeeMobilePage extends StatelessWidget {
  const EmployeeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        title: Text(
          'employee_title'.tr,
          style: AppTextStyles.appBarTitle(color: kPrimary),
        ),
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        actions: [
          Obx(() {
            if (Get.find<AuthController>().role != UserRole.admin) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: kPagePaddingHorizontal,
              child: OutlinedButton.icon(
                onPressed: () => Get.to(() => const GroupPage()),
                label: Text(
                  'employee_create_group_btn'.tr,
                  style: AppTextStyles.buttonLabel(),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ── Offline banner ────────────────────────────────────
          Obx(() {
            final offline = !Get.find<NetworkController>().isConnected.value;
            if (!offline) return const SizedBox.shrink();
            if (!offline || ctrl.isOfflineDialogOpen.value) {
              return const SizedBox.shrink();
            }
            return OfflineCardWidget(isDark: isDark);
          }),
          EmployeeFilterGroupChipsWidget(isDark: isDark, ctrl: ctrl),
          SearchBarWidget(
            isDark: isDark,
            onChanged: (v) => ctrl.searchQuery.value = v,
            hintText: 'employee_search_hint'.tr,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          ),
          Expanded(
            child: EmployeeListWidget(isDark: isDark, ctrl: ctrl),
          ),
        ],
      ),
      floatingActionButton: Get.find<AuthController>().role == UserRole.employee
          ? null
          : FloatingActionButton.extended(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              onPressed: () {
                if (!Get.find<NetworkController>().isConnected.value) {
                  ctrl.isOfflineDialogOpen.value = true;
                  showNoInternetDialog(
                    isDark: isDark,
                    redirectCount: 1,
                  ).then((_) => ctrl.isOfflineDialogOpen.value = false);
                  return;
                }
                ctrl.prepareForCreate();
                Get.bottomSheet(
                  const EmployeeBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              label: Text('employee_create_btn'.tr),
              icon: const Icon(Icons.person_add_rounded),
            ),
    );
  }
}
