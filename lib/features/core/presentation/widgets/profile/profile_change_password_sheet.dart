import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/password_input_widget.dart';

class ProfileChangePasswordSheet extends StatelessWidget {
  const ProfileChangePasswordSheet({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();

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
                'Change Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 20),

              // ── Current password ───────────────────────────
              PasswordInputWidget(
                controller: ctrl.currentPasswordController,
                label: 'Current Password',
                hint: 'Enter current password',
                isDark: isDark,
                errorText: _currentFieldError(err).isEmpty
                    ? null
                    : _currentFieldError(err),
              ),
              const SizedBox(height: 12),

              // ── New password ───────────────────────────────
              PasswordInputWidget(
                controller: ctrl.newPasswordController,
                label: 'New Password',
                hint: 'Enter new password',
                isDark: isDark,
                errorText: _newFieldError(err).isEmpty
                    ? null
                    : _newFieldError(err),
              ),
              if (_newFieldError(err).isEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Min 8 chars · uppercase · lowercase · number · special (e.g. Ditway@168)',
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
                label: 'Confirm New Password',
                hint: 'Re-enter new password',
                isDark: isDark,
                errorText: _confirmFieldError(err).isEmpty
                    ? null
                    : _confirmFieldError(err),
              ),
              const SizedBox(height: 20),

              // ── Submit button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: ctrl.isChangingPassword.value
                      ? null
                      : ctrl.submitChangePassword,
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
                      : const Text(
                          'Update Password',
                          style: TextStyle(
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

  String _currentFieldError(String err) {
    if (err.contains('required')) return 'Current password is required.';
    if (err.contains('incorrect')) return 'Current password is incorrect.';
    return '';
  }

  String _newFieldError(String err) {
    if (err.contains('required')) return 'New password is required.';
    if (err.contains('Min 8'))
      return 'Min 8 chars · uppercase · lowercase · number · special.';
    if (err.contains('match')) return 'Passwords do not match.';
    return '';
  }

  String _confirmFieldError(String err) {
    if (err.contains('required')) return 'Please confirm your new password.';
    if (err.contains('match')) return 'Passwords do not match.';
    return '';
  }
}
