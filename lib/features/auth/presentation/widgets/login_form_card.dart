import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_button.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_error_banner.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_headline.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_password_field.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_phone_field.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_qr_button.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: auth.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            LoginHeadline(isDark: isDark),
            const SizedBox(height: 36),
            LoginPhoneField(controller: auth.phoneController, isDark: isDark),
            const SizedBox(height: 16),
            Obx(
              () => LoginPasswordField(
                controller: auth.passwordController,
                isDark: isDark,
                obscure: auth.obscurePassword.value,
                onToggle: auth.obscurePassword.toggle,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final msg = auth.errorMessage.value;
              if (msg.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LoginErrorBanner(message: msg),
              );
            }),
            const SizedBox(height: 28),
            Obx(
              () => LoginButton(
                isLoading: auth.isLoading.value,
                onPressed: auth.submitLogin,
              ),
            ),
            const SizedBox(height: 16),
            const LoginQrButton(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
