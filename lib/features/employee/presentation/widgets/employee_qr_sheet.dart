import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/qr_code.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';

Future<void> showEmployeeQrSheet(
  BuildContext context, {
  required Employee employee,
  required bool isDark,
}) async {
  Get.dialog(const _QrGeneratingDialog(), barrierDismissible: false);

  final qrData = await Get.find<AuthController>().generateQrLogin(employee.id);

  if (Get.isDialogOpen ?? false) Get.back();
  if (qrData == null) return;
  if (!context.mounted) return;

  Get.bottomSheet(
    _EmployeeQrSheet(employee: employee, qrData: qrData, isDark: isDark),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _QrGeneratingDialog extends StatelessWidget {
  const _QrGeneratingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text(
              'Generating QR...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeQrSheet extends StatelessWidget {
  _EmployeeQrSheet({
    required this.employee,
    required this.qrData,
    required this.isDark,
  });

  final Employee employee;
  final QrLoginData qrData;
  final bool isDark;

  final _isSaving = false.obs;

  Future<void> _saveToGallery() async {
    if (_isSaving.value) return;
    _isSaving.value = true;
    try {
      final response = await Dio().get<List<int>>(
        qrData.qrCodeUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      await Gal.putImageBytes(Uint8List.fromList(response.data!));
      AppSnackbar.success('qr_save_success'.tr, '');
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) {
        AppSnackbar.error('qr_save_permission_denied'.tr, '');
      } else {
        AppSnackbar.error('qr_save_error'.tr, '');
      }
    } catch (_) {
      AppSnackbar.error('qr_save_error'.tr, '');
    } finally {
      _isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? kCardDark : const Color(0xFFF8F9FB);
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white54 : kTextMuted;

    final expiresAt = qrData.expiresAt;
    final expiryLabel =
        '${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')} ${expiresAt.hour.toString().padLeft(2, '0')}:${expiresAt.minute.toString().padLeft(2, '0')}:${expiresAt.second.toString().padLeft(2, '0')}}';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'qr_sheet_title'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                employee.fullName,
                style: const TextStyle(
                  fontSize: 14,
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              // QR image from server
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      qrData.qrCodeUrl,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kPrimary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) => const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            size: 48,
                            color: kTextMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Expiry notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(
                    '${'qr_sheet_expires'.tr} $expiryLabel',
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Save to Gallery button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving.value ? null : _saveToGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      disabledBackgroundColor: kPrimary.withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: _isSaving.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      _isSaving.value
                          ? 'qr_save_saving'.tr
                          : 'qr_save_action'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'qr_sheet_hint'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
