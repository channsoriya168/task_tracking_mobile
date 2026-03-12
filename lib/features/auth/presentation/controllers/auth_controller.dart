import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/routes/app_routes.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/fetch_profile_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

class AuthController extends GetxController {
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final FetchProfileUsecase _fetchProfileUsecase;
  late final CheckAuthUsecase _checkAuthUsecase;
  late final RefreshTokenUsecase _refreshTokenUsecase;
  late final ChangePasswordUsecase _changePasswordUsecase;

  final Rx<Auth?> currentAuth = Rx<Auth?>(null);
  final Rx<EmployeeProfile?> profile = Rx<EmployeeProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

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
    _logoutUsecase = LogoutUsecase(repo);
    _fetchProfileUsecase = FetchProfileUsecase(repo);
    _checkAuthUsecase = CheckAuthUsecase(repo);
    _changePasswordUsecase = ChangePasswordUsecase(repo);
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
      fetchProfile();
      Get.find<NavigationController>().changePage(0);
      Get.offAllNamed(AppRoutes.mainPage);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Fetch profile ─────────────────────────────────────────
  Future<void> fetchProfile() async {
    try {
      final profile = await _fetchProfileUsecase();
      this.profile.value = profile;
    } catch (_) {
      // Silently fail — currentAuth from login/restore is still valid
    }
  }

  // ── Check auth (called from Splash / route guards) ────────
  /// Returns `true` if the session is valid (or was silently refreshed).
  /// Returns `false` if the user must log in again.
  /// On success, kicks off a background profile fetch to populate [currentAuth].
  Future<bool> checkAuth() async {
    try {
      final auth = await _checkAuthUsecase();
      currentAuth.value = auth;
      fetchProfile();
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
      final refreshed = await _refreshTokenUsecase();
      currentAuth.value = refreshed;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Change password ───────────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) => _changePasswordUsecase(
    currentPassword: currentPassword,
    newPassword: newPassword,
    confirmNewPassword: confirmNewPassword,
  );

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _logoutUsecase();
    currentAuth.value = null;
    Get.find<NavigationController>().changePage(0);
    Get.offAllNamed(AppRoutes.login);
  }
}
