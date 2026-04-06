import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/password_input_widget.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';

class ProfileChangePasswordSheet extends StatelessWidget {
  const ProfileChangePasswordSheet({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Obx(() {
          final err = ctrl.changePasswordError.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle ────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Title + subtitle ───────────────────────────
              Text(
                'change_pwd_title'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'change_pwd_subtitle'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : kTextMuted,
                ),
              ),
              const SizedBox(height: 20),

              // ── Current password ───────────────────────────
              PasswordInputWidget(
                controller: ctrl.currentPasswordController,
                label: 'change_pwd_current'.tr,
                hint: 'change_pwd_current_hint'.tr,
                isDark: isDark,
                errorText:
                    _currentFieldError(
                      err,
                      ctrl.currentPasswordController.text.trim().isEmpty,
                    ).isEmpty
                    ? null
                    : _currentFieldError(
                        err,
                        ctrl.currentPasswordController.text.trim().isEmpty,
                      ),
              ),
              const SizedBox(height: 12),

              // ── New password ───────────────────────────────
              PasswordInputWidget(
                controller: ctrl.newPasswordController,
                label: 'change_pwd_new'.tr,
                hint: 'change_pwd_new_hint'.tr,
                isDark: isDark,
                errorText:
                    _newFieldError(
                      err,
                      ctrl.newPasswordController.text.isEmpty,
                    ).isEmpty
                    ? null
                    : _newFieldError(
                        err,
                        ctrl.newPasswordController.text.isEmpty,
                      ),
              ),
              if (_newFieldError(
                err,
                ctrl.newPasswordController.text.isEmpty,
              ).isEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: isDark ? Colors.white38 : kTextMuted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'change_pwd_hint'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : kTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // ── Confirm password ───────────────────────────
              PasswordInputWidget(
                controller: ctrl.confirmPasswordController,
                label: 'change_pwd_confirm'.tr,
                hint: 'change_pwd_confirm_hint'.tr,
                isDark: isDark,
                errorText:
                    _confirmFieldError(
                      err,
                      ctrl.confirmPasswordController.text.isEmpty,
                    ).isEmpty
                    ? null
                    : _confirmFieldError(
                        err,
                        ctrl.confirmPasswordController.text.isEmpty,
                      ),
              ),
              const SizedBox(height: 20),

              // ── Submit button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: ctrl.isChangingPassword.value
                      ? null
                      : ctrl.changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kPrimary.withAlpha(120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: ctrl.isChangingPassword.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'change_pwd_btn'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _currentFieldError(String err, bool isCurrentPasswordEmpty) {
    if (err.contains('required') && isCurrentPasswordEmpty) {
      return 'change_pwd_err_current_required'.tr;
    }
    if (err.contains('incorrect')) return 'change_pwd_err_current_incorrect'.tr;
    return '';
  }

  String _newFieldError(String err, bool isNewPasswordEmpty) {
    if (err.contains('required') && isNewPasswordEmpty) {
      return 'change_pwd_err_new_required'.tr;
    }
    if (err.contains('Min 8')) return 'change_pwd_err_new_weak'.tr;
    return '';
  }

  String _confirmFieldError(String err, bool isConfirmPasswordEmpty) {
    if (err.contains('required') && isConfirmPasswordEmpty) {
      return 'change_pwd_err_confirm_required'.tr;
    }
    if (err.contains('match')) return 'change_pwd_err_no_match'.tr;
    return '';
  }
}
