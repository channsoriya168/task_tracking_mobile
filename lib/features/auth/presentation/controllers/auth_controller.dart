import 'dart:io';

import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/network/push_notification_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/fetch_profile_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/validators.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

class AuthController extends GetxController {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final FetchProfileUsecase fetchProfileUsecase;
  final CheckAuthUsecase checkAuthUsecase;
  final RefreshTokenUsecase refreshTokenUsecase;
  final ChangePasswordUsecase changePasswordUsecase;
  final UpdateProfileUsecase updateProfileUsecase;

  AuthController({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.fetchProfileUsecase,
    required this.checkAuthUsecase,
    required this.refreshTokenUsecase,
    required this.changePasswordUsecase,
    required this.updateProfileUsecase,
  });

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
  final RxBool isChangingPassword = false.obs;
  final RxString changePasswordError = ''.obs;
  final RxBool isUploadingImage = false.obs;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool get isAuthenticated => currentAuth.value != null;

  /// Maps the API role string (e.g. "Admin") to [UserRole].
  UserRole? get role {
    final r = currentAuth.value?.primaryRole.toLowerCase();
    if (r == 'admin') return UserRole.admin;
    if (r == 'manager') return UserRole.manager;
    if (r == 'employee') return UserRole.employee;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
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
  void submitLogin() {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
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
      fetchProfile();

      // Register FCM token with backend
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

  // ── Fetch profile ─────────────────────────────────────────
  Future<void> fetchProfile() async {
    try {
      final profile = await fetchProfileUsecase();
      this.profile.value = profile;
    } catch (_) {
      // Silently fail — currentAuth from login/restore is still valid
    }
  }

  // ── Check auth ──────────────────────────────────────────
  Future<bool> checkAuth() async {
    try {
      final auth = await checkAuthUsecase();
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
      final refreshed = await refreshTokenUsecase();
      currentAuth.value = refreshed;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Change password ───────────────────────────────────────
  Future<void> submitChangePassword() async {
    if (currentPasswordController.text.trim().isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      changePasswordError.value = 'All fields are required.';
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      changePasswordError.value = 'New passwords do not match.';
      return;
    }
    final passError = Validators.strongPassword(newPasswordController.text);
    if (passError != null) {
      changePasswordError.value = passError;
      return;
    }

    isChangingPassword.value = true;
    changePasswordError.value = '';
    try {
      await changePasswordUsecase(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text,
        confirmNewPassword: confirmPasswordController.text,
      );
      clearChangePasswordForm();
      Get.back();
      AppSnackbar.success('snack_success'.tr, 'snack_pwd_changed'.tr);
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
    changePasswordError.value = '';
  }

  // ── Update profile image ──────────────────────────────────
  Future<void> pickAndUploadProfileImage(ImageSource source) async {
    final pickImage = Get.find<PickAndCompressImageUseCase>();
    final File? file = await pickImage(source);
    if (file == null) return;
    isUploadingImage.value = true;
    try {
      await updateProfileUsecase(image: file);
      await fetchProfile();
      AppSnackbar.success('snack_success'.tr, 'snack_photo_updated'.tr);
    } catch (e) {
      AppSnackbar.error('snack_error'.tr, e.toString());
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> removeProfileImage() async {
    isUploadingImage.value = true;
    try {
      await updateProfileUsecase(removeImage: true);
      await fetchProfile();
      AppSnackbar.success('snack_success'.tr, 'snack_photo_removed'.tr);
    } catch (e) {
      AppSnackbar.error('snack_error'.tr, e.toString());
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    // Unregister FCM token before clearing session
    await _unregisterPushToken();

    await logoutUsecase();
    currentAuth.value = null;
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
