import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/qr_scanner_page.dart';

class LoginQrButton extends StatelessWidget {
  const LoginQrButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Get.to(() => const QrScannerPage()),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: Text('login_qr_sign_in'.tr),
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonLabel(),
        ),
      ),
    );
  }
}
