import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
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
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                    Obx(
                      () => Text(
                        'employee_members'.trParams({
                          'count': '${ctrl.employees.length}',
                        }),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _TabletSearchField(isDark: isDark, ctrl: ctrl),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => Get.to(() => const GroupPage()),
                  label: Text('employee_create_group_btn'.tr),
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

// ── Inline search field ────────────────────────────────────────
class _TabletSearchField extends StatelessWidget {
  const _TabletSearchField({required this.isDark, required this.ctrl});

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 40,
      child: TextField(
        onChanged: (v) => ctrl.searchQuery.value = v,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white : kTextDark,
        ),
        decoration: InputDecoration(
          hintText: 'employee_search_hint'.tr,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          filled: true,
          fillColor: isDark ? kCardDark : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(18)
                  : Colors.grey.withAlpha(40),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(18)
                  : Colors.grey.withAlpha(40),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kPrimary),
          ),
        ),
      ),
    );
  }
}
