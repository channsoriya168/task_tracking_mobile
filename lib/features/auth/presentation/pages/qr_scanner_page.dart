import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  void _onDetect(BarcodeCapture capture) {
    final auth = Get.find<AuthController>();
    if (auth.isLoading.value) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    Get.back();
    auth.qrLogin(raw);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        title: Text(
          'login_qr_scan_title'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : kTextDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : kTextDark,
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: kPrimary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              'login_qr_scan_hint'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}