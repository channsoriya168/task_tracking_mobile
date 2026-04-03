import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_form_field.dart';

class LoginPhoneField extends StatelessWidget {
  const LoginPhoneField({
    super.key,
    required this.controller,
    required this.isDark,
  });
  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LoginFormField(
      label: 'login_phone_label'.tr,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        style: TextStyle(
          color: isDark ? Colors.white : kTextDark,
          fontSize: 15,
        ),
        decoration: loginInputDecoration(
          hint: 'login_phone_hint'.tr,
          icon: Icons.phone_outlined,
          isDark: isDark,
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'login_phone_required'.tr;
          final digits = v.trim().replaceAll(RegExp(r'\D'), '');
          if (digits.length < 9 || digits.length > 12) {
            return 'login_phone_invalid'.tr;
          }
          return null;
        },
      ),
    );
  }
}