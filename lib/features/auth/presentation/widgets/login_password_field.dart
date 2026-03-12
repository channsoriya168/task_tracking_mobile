import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
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
      label: 'Password',
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          color: isDark ? Colors.white : kTextDark,
          fontSize: 15,
        ),
        decoration: loginInputDecoration(
          hint: 'Enter your password',
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
          if (v == null || v.isEmpty) return 'Password is required';
          if (v.length < 6) return 'At least 6 characters required';
          return null;
        },
      ),
    );
  }
}
