import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/qr_scanner_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_error_banner.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_headline.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.isDark,
    this.width,
    this.height,
  });
  final bool isDark;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Container(
      width: width,
      height: height,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          LoginHeadline(isDark: isDark),
          const SizedBox(height: 36),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                size: 56,
                color: kPrimary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Obx(() {
            final msg = auth.errorMessage.value;
            if (msg.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LoginErrorBanner(message: msg),
            );
          }),
          Obx(() {
            final busy = auth.isLoading.value || auth.isPickingQr.value;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: busy ? null : () => Get.to(() => const QrScannerPage()),
                icon: (auth.isLoading.value && !auth.isPickingQr.value)
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.qr_code_scanner_rounded),
                label: Text('login_qr_sign_in'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  disabledBackgroundColor: kPrimary.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.buttonLabel(),
                  elevation: 0,
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            final busy = auth.isPickingQr.value || auth.isLoading.value;
            return SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => auth.pickQrFromGallery(),
                icon: auth.isPickingQr.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimary.withValues(alpha: 0.6),
                        ),
                      )
                    : const Icon(Icons.photo_library_rounded),
                label: Text('login_qr_upload'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: BorderSide(
                    color: busy
                        ? kPrimary.withValues(alpha: 0.4)
                        : kPrimary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.buttonLabel(),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
