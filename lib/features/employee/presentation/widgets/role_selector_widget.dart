import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/user_role.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';

class RoleSelectorWidget extends StatelessWidget {
  const RoleSelectorWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

  final EmployeeController controller;
  final bool isDark;

  static const _roles = ['Employee', 'Manager'];

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.role != UserRole.admin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.formLabel(
              color: isDark ? Colors.white : kTextDark,
            ),
            children: [
              TextSpan(text: 'emp_form_role_label'.tr),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        Obx(
          () => Row(
            children: _roles.map((role) {
              final isSelected = controller.selectedRole.value == role;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => controller.selectedRole.value = role,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimary.withValues(alpha: 0.12)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? kPrimary
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.grey[300]!),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: kPrimary,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          role,
                          style: AppTextStyles.chipLabel(
                            selected: isSelected,
                            color: isSelected
                                ? kPrimary
                                : (isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
