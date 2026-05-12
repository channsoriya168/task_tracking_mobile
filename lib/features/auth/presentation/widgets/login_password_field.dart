import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_form_field.dart';

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.isDark,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final bool isDark;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return LoginFormField(
      label: 'login_password_label'.tr,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        textInputAction: TextInputAction.done,
        style: AppTextStyles.inputText(
          color: isDark ? Colors.white : kTextDark,
        ),
        decoration: loginInputDecoration(
          hint: 'login_password_hint'.tr,
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: kTextMuted,
            ),
            onPressed: onToggle,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'login_password_required'.tr;
          if (v.length < 6) return 'login_password_min'.tr;
          return null;
        },
      ),
    );
  }
}
