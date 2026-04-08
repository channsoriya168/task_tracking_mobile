// ── Header ────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/group/presentation/pages/group_page.dart';

class EmployeeHeaderWidget extends StatelessWidget {
  const EmployeeHeaderWidget({required this.isDark, required this.ctrl});

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPagePaddingHorizontal,
      child: Row(
        children: [
          Text(
            'employee_title'.tr,
            style: AppTextStyles.appBarTitle(
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => Get.to(() => const GroupPage()),
            label: Text(
              'employee_create_group_btn'.tr,
              style: TextStyle(
                fontFamily: Get.locale?.languageCode == 'km'
                    ? 'Siemreap'
                    : 'Kantumruy Pro',
              ),
            ),
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
