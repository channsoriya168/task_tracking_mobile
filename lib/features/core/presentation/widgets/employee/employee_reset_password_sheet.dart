import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/password_input_widget.dart';

void showResetPasswordSheet(
  BuildContext context, {
  required Employee employee,
  required EmployeeController ctrl,
  required bool isDark,
}) {
  ctrl.openResetPasswordForm();
  Get.bottomSheet(
    _ResetPasswordSheet(employee: employee, ctrl: ctrl, isDark: isDark),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _ResetPasswordSheet extends StatelessWidget {
  const _ResetPasswordSheet({
    required this.employee,
    required this.ctrl,
    required this.isDark,
  });

  final Employee employee;
  final EmployeeController ctrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'snack_reset_pwd'.tr,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                      Text(
                        employee.fullName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // New Password
              Obx(
                () => PasswordInputWidget(
                  controller: ctrl.resetPasswordCtrl,
                  label: 'change_pwd_new'.tr,
                  hint: 'change_pwd_new_hint'.tr,
                  isDark: isDark,
                  isRequired: true,
                  errorText: ctrl.resetPasswordErrors['newPassword'],
                ),
              ),
              const SizedBox(height: 12),

              // Confirm Password
              Obx(
                () => PasswordInputWidget(
                  controller: ctrl.resetConfirmPasswordCtrl,
                  label: 'change_pwd_confirm'.tr,
                  hint: 'change_pwd_confirm_hint'.tr,
                  isDark: isDark,
                  isRequired: true,
                  errorText: ctrl.resetPasswordErrors['confirmPassword'],
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ctrl.isResettingPassword.value
                        ? null
                        : () => ctrl.resetPasswordForEmployee(employee.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMediumPriority,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kMediumPriority.withValues(
                        alpha: 0.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: ctrl.isResettingPassword.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'snack_reset_pwd'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
