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
import 'package:task_tracking_mobile/app/utils/validators.dart';
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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool isChangingPassword = false.obs;
  final RxString changePasswordError = ''.obs;

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
    _refreshTokenUsecase = RefreshTokenUsecase(repo);
    _changePasswordUsecase = ChangePasswordUsecase(repo);
    _initChangePasswordListeners();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
      Get.snackbar(
        'Welcome back, ${auth.fullName}!',
        '',
        backgroundColor: const Color(0xFF2ED573),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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
  Future<void> submitChangePassword() async {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      changePasswordError.value = 'All fields are required.';
      return;
    }
    if (newPass != confirm) {
      changePasswordError.value = 'New passwords do not match.';
      return;
    }
    final passError = Validators.strongPassword(newPass);
    if (passError != null) {
      changePasswordError.value = passError;
      return;
    }

    isChangingPassword.value = true;
    changePasswordError.value = '';
    try {
      await _changePasswordUsecase(
        currentPassword: current,
        newPassword: newPass,
        confirmNewPassword: confirm,
      );
      clearChangePasswordForm();
      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully.',
        backgroundColor: const Color(0xFF2ED573),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      changePasswordError.value = e.toString();
    } finally {
      isChangingPassword.value = false;
    }
  }

  void _initChangePasswordListeners() {
    void clearError() {
      if (changePasswordError.value.isNotEmpty) {
        changePasswordError.value = '';
      }
    }
    currentPasswordController.addListener(clearError);
    newPasswordController.addListener(clearError);
    confirmPasswordController.addListener(clearError);
  }

  void clearChangePasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    obscureCurrent.value = true;
    obscureNew.value = true;
    obscureConfirm.value = true;
    changePasswordError.value = '';
  }

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _logoutUsecase();
    currentAuth.value = null;
    Get.find<NavigationController>().changePage(0);
    Get.offAllNamed(AppRoutes.login);
  }
}
