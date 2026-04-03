import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/app/widgets/language_switcher_widget.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_bg_circles.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_button.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_error_banner.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_headline.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_password_field.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_phone_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Stack(
        children: [
          // ── Decorative background circles ──────────────────
          LoginBgCircles(isDark: isDark),

          // ── Main content ───────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar: language switcher ─────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LanguageSwitcherPill(isDark: isDark),
                    ],
                  ),
                ),

                // ── Login form ─────────────────────────────
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: kPagePaddingWithBottom,
                      child: Form(
                        key: auth.loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LoginHeadline(isDark: isDark),
                            const SizedBox(height: 36),
                            LoginPhoneField(
                              controller: auth.phoneController,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => LoginPasswordField(
                                controller: auth.passwordController,
                                isDark: isDark,
                                obscure: auth.obscurePassword.value,
                                onToggle: () => auth.obscurePassword.toggle(),
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
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
