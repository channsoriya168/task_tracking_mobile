import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_tracking_mobile/core/services/push_notification_service.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/qr_code.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/generate_qr_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/qr_login_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:task_tracking_mobile/core/constants/user_role.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';

class AuthController extends GetxController {
  final LogoutUsecase logoutUsecase;
  final CheckAuthUsecase checkAuthUsecase;
  final RefreshTokenUsecase refreshTokenUsecase;
  final QrLoginUsecase qrLoginUsecase;
  final GenerateQrUsecase generateQrUsecase;

  AuthController({
    required this.logoutUsecase,
    required this.checkAuthUsecase,
    required this.refreshTokenUsecase,
    required this.qrLoginUsecase,
    required this.generateQrUsecase,
  });

  final Rx<Auth?> currentAuth = Rx<Auth?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isAuthenticated => currentAuth.value != null;

  UserRole? get role {
    final r = currentAuth.value?.primaryRole.toLowerCase();
    if (r == 'admin') return UserRole.admin;
    if (r == 'manager') return UserRole.manager;
    if (r == 'employee') return UserRole.employee;
    return null;
  }

  // ── QR Login ─────────────────────────────────────────────
  Future<void> qrLogin(String token) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final auth = await qrLoginUsecase(token);
      currentAuth.value = auth;
      Get.find<ProfileController>().fetchProfile();
      _registerPushToken();
      Get.find<NavigationController>().changePage(0);
      Get.offAllNamed(AppRoutes.mainPage);
      AppSnackbar.success(
        'snack_welcome'.trParams({'name': auth.fullName}),
        '',
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── QR from Gallery ──────────────────────────────────────
  final RxBool isPickingQr = false.obs;

  Future<void> pickQrFromGallery() async {
    if (isPickingQr.value) return;
    isPickingQr.value = true;

    File? tempFile;
    MobileScannerController? scanner;
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/qr_scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(bytes);

      // Create controller inside try so any init failure is caught and logged.
      scanner = MobileScannerController();
      final capture = await scanner.analyzeImage(tempFile.path);
      final raw = capture?.barcodes.firstOrNull?.rawValue;
      if (raw == null || raw.isEmpty) {
        AppSnackbar.error('login_qr_not_found'.tr, '');
        return;
      }
      await qrLogin(raw);
    } catch (e, s) {
      AppSnackbar.error('login_qr_not_found'.tr, '');
    } finally {
      await scanner?.dispose();
      await tempFile?.delete().catchError((_) => tempFile!);
      isPickingQr.value = false;
    }
  }

  // ── Generate QR ───────────────────────────────────────────
  Future<QrLoginData?> generateQrLogin(String employeeId) async {
    try {
      return await generateQrUsecase(employeeId);
    } catch (e) {
      AppSnackbar.error('qr_generate_error'.tr, e.toString());
      return null;
    }
  }

  // ── Check auth ──────────────────────────────────────────
  Future<bool> checkAuth() async {
    try {
      final auth = await checkAuthUsecase();
      currentAuth.value = auth;
      Get.find<ProfileController>().fetchProfile();
      _registerPushToken();
      return true;
    } catch (_) {
      currentAuth.value = null;
      return false;
    }
  }

  // ── Refresh token ─────────────────────────────────────────
  /// Called by [ApiClient]'s interceptor on 401. Returns true on success.
  Future<bool> refreshToken() async {
    try {
      final refreshed = await refreshTokenUsecase();
      currentAuth.value = refreshed;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _unregisterPushToken();
    await logoutUsecase();
    currentAuth.value = null;
    Get.find<ProfileController>().clearProfile();
    Get.find<NavigationController>().changePage(0);
    Get.offAllNamed(AppRoutes.login);
  }

  // ── Push notification helpers ────────────────────────────
  void _registerPushToken() {
    try {
      final pushService = Get.find<PushNotificationService>();
      pushService.registerToken();
    } catch (_) {
      // PushNotificationService may not be initialized yet — silently skip
    }
  }

  Future<void> _unregisterPushToken() async {
    try {
      final pushService = Get.find<PushNotificationService>();
      await pushService.unregisterToken();
    } catch (_) {
      // Silently ignore — logout should always succeed
    }
  }
}
