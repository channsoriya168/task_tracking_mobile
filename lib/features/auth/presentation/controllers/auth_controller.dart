import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

class AuthController extends GetxController {
  late final LoginUsecase _loginUsecase;
  late final RestoreSessionUsecase _restoreSessionUsecase;
  late final LogoutUsecase _logoutUsecase;

  final Rx<Auth?> currentAuth = Rx<Auth?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool get isAuthenticated => currentAuth.value != null;

  /// Maps the API role string (e.g. "Admin") to [UserRole].
  UserRole? get role {
    final r = currentAuth.value?.primaryRole.toLowerCase();
    if (r == 'admin') return UserRole.Admin;
    if (r == 'manager') return UserRole.Manager;
    if (r == 'employee') return UserRole.Employee;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    final repo = Get.find<AuthRepository>();
    _loginUsecase = LoginUsecase(repo);
    _restoreSessionUsecase = RestoreSessionUsecase(repo);
    _logoutUsecase = LogoutUsecase(repo);
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ── Login ────────────────────────────────────────────────
  Future<void> login() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final auth = await _loginUsecase(
        phoneController.text.trim(),
        passwordController.text,
      );
      currentAuth.value = auth;
      Get.find<NavigationController>().changePage(0);
      Get.offAllNamed(AppRoutes.mainPage);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Restore session (called from Splash) ─────────────────
  Future<bool> restoreSession() async {
    final auth = await _restoreSessionUsecase();
    if (auth != null) {
      currentAuth.value = auth;
      return true;
    }
    return false;
  }

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _logoutUsecase();
    currentAuth.value = null;
    Get.find<NavigationController>().changePage(0);
    Get.offAllNamed(AppRoutes.login);
  }
}
