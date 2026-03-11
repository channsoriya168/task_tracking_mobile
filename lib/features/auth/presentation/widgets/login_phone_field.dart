import 'package:flutter/material.dart';
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
      label: 'Phone Number',
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        style: TextStyle(
          color: isDark ? Colors.white : kTextDark,
          fontSize: 15,
        ),
        decoration: loginInputDecoration(
          hint: '0884311016',
          icon: Icons.phone_outlined,
          isDark: isDark,
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Phone number is required';
          final digits = v.trim().replaceAll(RegExp(r'\D'), '');
          if (digits.length < 9 || digits.length > 12) {
            return 'Enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }
}
