import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/network/push_notification_service.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/profile/presentation/controllers/profile_controller.dart';

class AuthController extends GetxController {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final CheckAuthUsecase checkAuthUsecase;
  final RefreshTokenUsecase refreshTokenUsecase;

  AuthController({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.checkAuthUsecase,
    required this.refreshTokenUsecase,
  });

  final Rx<Auth?> currentAuth = Rx<Auth?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool get isAuthenticated => currentAuth.value != null;

  UserRole? get role {
    final r = currentAuth.value?.primaryRole.toLowerCase();
    if (r == 'admin') return UserRole.admin;
    if (r == 'manager') return UserRole.manager;
    if (r == 'employee') return UserRole.employee;
    return null;
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ── Login ────────────────────────────────────────────────
  void submitLogin(GlobalKey<FormState> formKey) {
    if (!(formKey.currentState?.validate() ?? false)) return;
    login();
  }

  Future<void> login() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final auth = await loginUsecase(
        phoneController.text.trim(),
        passwordController.text,
      );
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
    AppSnackbar.success('snack_logged_out'.tr, 'snack_logged_out_msg'.tr);
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
