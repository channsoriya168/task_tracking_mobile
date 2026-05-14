import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/tablet_search_field_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_bottom_sheet.dart';
import 'package:task_tracking_mobile/features/group/presentation/pages/group_page.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_filter_group_chips_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_list_widget.dart';

class EmployeeTabletPage extends StatelessWidget {
  const EmployeeTabletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Title + Search + Manage Groups ─────────────
          Padding(
            padding: kPagePaddingHorizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title + count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'employee_title'.tr,
                      style: AppTextStyles.appBarTitle(color: kPrimary),
                    ),
                  ],
                ),
                const Spacer(),
                TabletSearchFieldWidget(
                  isDark: isDark,
                  onChanged: (v) => ctrl.searchQuery.value = v,
                  hintText: 'employee_search_hint'.tr,
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
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
              ],
            ),
          ),

          // ── Row 2: Filter chips ───────────────────────────────
          const SizedBox(height: 8),
          EmployeeFilterGroupChipsWidget(isDark: isDark, ctrl: ctrl),
          const SizedBox(height: 8),

          // ── Employee list ────────────────────────────────────
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
              icon: const Icon(Icons.add_rounded),
            ),
    );
  }
}
