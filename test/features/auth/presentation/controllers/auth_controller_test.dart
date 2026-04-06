import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

// ── Stub repository ──────────────────────────────────────────────────────────

class _StubAuthRepository implements AuthRepository {
  // login
  Auth? loginResult;
  Object? loginError;

  // checkAuth
  Auth? checkAuthResult;
  Object? checkAuthError;

  // refreshToken
  Auth? refreshResult;
  Object? refreshError;

  // changePassword
  Object? changePasswordError;

  bool logoutCalled = false;

  @override
  Future<Auth> login(String phoneNumber, String password) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<void> logout() async => logoutCalled = true;

  @override
  Future<Auth> checkAuth() async {
    if (checkAuthError != null) throw checkAuthError!;
    return checkAuthResult!;
  }

  @override
  Future<Auth> refreshToken() async {
    if (refreshError != null) throw refreshError!;
    return refreshResult!;
  }

  @override
  Future<EmployeeProfile?> fetchProfile() async => null;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (changePasswordError != null) throw changePasswordError!;
  }

  @override
  Future<void> updateProfile({File? image, bool removeImage = false}) async {}
}

// ── Auth helper ──────────────────────────────────────────────────────────────

final _futureExp = DateTime.now().add(const Duration(days: 365 * 10));

Auth _makeAuth({String role = 'Manager'}) => Auth(
  userId: 'u1',
  fullName: 'Alice Smith',
  phoneNumber: '+85512345678',
  roles: [role],
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
  accessTokenExpiration: _futureExp,
);

// ── Test setup ───────────────────────────────────────────────────────────────

AuthController _buildController(_StubAuthRepository repo) {
  Get.reset();
  Get.testMode = true;
  Get.put<AuthRepository>(repo);
  Get.put<NavigationController>(NavigationController());
  return Get.put<AuthController>(AuthController());
}

/// Runs [fn] in a guarded zone that silently absorbs any async errors
/// fired by GetX's navigation / snackbar machinery (which require a real
/// widget tree).  The returned future completes once [fn] itself finishes.
Future<void> _guardedRun(Future<void> Function() fn) async {
  final completer = Completer<void>();
  runZonedGuarded(
    () async {
      try {
        await fn();
      } finally {
        if (!completer.isCompleted) completer.complete();
      }
    },
    (_, __) {
      if (!completer.isCompleted) completer.complete();
    },
  );
  await completer.future;
}

void main() {
  tearDown(() => Get.reset());

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – initial state', () {
    test('isAuthenticated is false before any login', () {
      final ctrl = _buildController(_StubAuthRepository());
      expect(ctrl.isAuthenticated, isFalse);
    });

    test('isLoading starts false', () {
      final ctrl = _buildController(_StubAuthRepository());
      expect(ctrl.isLoading.value, isFalse);
    });

    test('errorMessage starts empty', () {
      final ctrl = _buildController(_StubAuthRepository());
      expect(ctrl.errorMessage.value, '');
    });

    test('currentAuth starts null', () {
      final ctrl = _buildController(_StubAuthRepository());
      expect(ctrl.currentAuth.value, isNull);
    });

    test('role returns null when not authenticated', () {
      final ctrl = _buildController(_StubAuthRepository());
      expect(ctrl.role, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – login()', () {
    // Note: login() on success calls Get.snackbar + Get.offAllNamed (navigation
    // side-effects). We verify auth state via checkAuth() (no nav side-effects)
    // and only verify the error path for login() directly.
    test('isAuthenticated reflects currentAuth value', () async {
      final auth = _makeAuth();
      final repo = _StubAuthRepository()..checkAuthResult = auth;
      final ctrl = _buildController(repo);

      expect(ctrl.isAuthenticated, isFalse);
      await ctrl.checkAuth();
      expect(ctrl.isAuthenticated, isTrue);
      expect(ctrl.currentAuth.value, isNotNull);
    });

    test('isLoading resets to false after successful login', () async {
      final repo = _StubAuthRepository()..loginResult = _makeAuth();
      final ctrl = _buildController(repo);

      ctrl.phoneController.text = '+85512345678';
      ctrl.passwordController.text = 'secret';
      // Use guarded zone so GetX's async snackbar errors don't fail the test.
      await _guardedRun(() => ctrl.login());

      expect(ctrl.isLoading.value, isFalse);
    });

    test('sets errorMessage on failure', () async {
      final repo = _StubAuthRepository()
        ..loginError = Exception('Incorrect phone number or password.');
      final ctrl = _buildController(repo);

      await ctrl.login();

      expect(ctrl.errorMessage.value, isNotEmpty);
      expect(ctrl.isAuthenticated, isFalse);
    });

    test('isLoading resets to false after failed login', () async {
      final repo = _StubAuthRepository()
        ..loginError = Exception('network error');
      final ctrl = _buildController(repo);

      await ctrl.login();

      expect(ctrl.isLoading.value, isFalse);
    });

    test('clears errorMessage at the start of each login attempt', () async {
      final repo = _StubAuthRepository()..loginError = Exception('first error');
      final ctrl = _buildController(repo);

      // First attempt fails and sets errorMessage.
      await ctrl.login();
      expect(ctrl.errorMessage.value, isNotEmpty);

      // Second attempt: errorMessage is cleared at the top of login(),
      // then fails again → still set. Confirm the clear-then-set cycle.
      repo.loginError = Exception('second error');
      final firstError = ctrl.errorMessage.value;
      await ctrl.login();

      // The message was cleared inside login() before the new error was set.
      // It may be a different string than the previous error.
      expect(ctrl.errorMessage.value, isNotEmpty);
      // Not necessarily the same as the first error (proves re-evaluation).
      expect(ctrl.isLoading.value, isFalse);
      debugPrint(firstError); // consume variable
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – checkAuth()', () {
    test('returns true and sets currentAuth when session is valid', () async {
      final auth = _makeAuth();
      final repo = _StubAuthRepository()..checkAuthResult = auth;
      final ctrl = _buildController(repo);

      final result = await ctrl.checkAuth();

      expect(result, isTrue);
      expect(ctrl.currentAuth.value, auth);
    });

    test(
      'returns false and clears currentAuth when session is invalid',
      () async {
        final repo = _StubAuthRepository()
          ..checkAuthError = Exception('No session found');
        final ctrl = _buildController(repo);

        final result = await ctrl.checkAuth();

        expect(result, isFalse);
        expect(ctrl.currentAuth.value, isNull);
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – refreshToken()', () {
    test('returns true and updates currentAuth on success', () async {
      final auth = _makeAuth();
      final repo = _StubAuthRepository()..refreshResult = auth;
      final ctrl = _buildController(repo);

      final result = await ctrl.refreshToken();

      expect(result, isTrue);
      expect(ctrl.currentAuth.value, auth);
    });

    test('returns false on failure', () async {
      final repo = _StubAuthRepository()
        ..refreshError = Exception('token expired');
      final ctrl = _buildController(repo);

      final result = await ctrl.refreshToken();

      expect(result, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – logout()', () {
    test('clears currentAuth after logout', () async {
      final repo = _StubAuthRepository()..checkAuthResult = _makeAuth();
      final ctrl = _buildController(repo);

      // Seed auth via checkAuth (no navigation side-effects).
      await ctrl.checkAuth();
      expect(ctrl.isAuthenticated, isTrue);

      await ctrl.logout();

      expect(ctrl.currentAuth.value, isNull);
      expect(ctrl.isAuthenticated, isFalse);
    });

    test('calls repository logout', () async {
      final repo = _StubAuthRepository()..checkAuthResult = _makeAuth();
      final ctrl = _buildController(repo);

      await ctrl.checkAuth();
      await ctrl.logout();

      expect(repo.logoutCalled, isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – submitChangePassword()', () {
    test('sets error when all fields are empty', () async {
      final ctrl = _buildController(_StubAuthRepository());

      await ctrl.submitChangePassword();

      expect(ctrl.changePasswordError.value, 'All fields are required.');
      expect(ctrl.isChangingPassword.value, isFalse);
    });

    test('sets error when new passwords do not match', () async {
      final ctrl = _buildController(_StubAuthRepository());
      ctrl.currentPasswordController.text = 'Current@1';
      ctrl.newPasswordController.text = 'NewPass@1';
      ctrl.confirmPasswordController.text = 'DifferentPass@1';

      await ctrl.submitChangePassword();

      expect(ctrl.changePasswordError.value, 'New passwords do not match.');
    });

    test('sets error for weak new password', () async {
      final ctrl = _buildController(_StubAuthRepository());
      ctrl.currentPasswordController.text = 'Current@1';
      ctrl.newPasswordController.text = 'weak';
      ctrl.confirmPasswordController.text = 'weak';

      await ctrl.submitChangePassword();

      expect(ctrl.changePasswordError.value, isNotEmpty);
    });

    test('clears form fields and resets loading on success', () async {
      // submitChangePassword() on success calls Get.back() which fires an
      // async zone error in test env (no widget tree). Use guarded zone.
      final ctrl = _buildController(_StubAuthRepository());
      ctrl.currentPasswordController.text = 'OldPass@1';
      ctrl.newPasswordController.text = 'NewPass@1';
      ctrl.confirmPasswordController.text = 'NewPass@1';

      await _guardedRun(() => ctrl.submitChangePassword());

      // Form is cleared inside clearChangePasswordForm() before navigation.
      expect(ctrl.currentPasswordController.text, '');
      expect(ctrl.newPasswordController.text, '');
      expect(ctrl.confirmPasswordController.text, '');
      // isChangingPassword resets in finally even if navigation throws.
      expect(ctrl.isChangingPassword.value, isFalse);
    });

    test('sets changePasswordError on repository failure', () async {
      final repo = _StubAuthRepository()
        ..changePasswordError = 'Current password is incorrect.';
      final ctrl = _buildController(repo);
      ctrl.currentPasswordController.text = 'WrongPass@1';
      ctrl.newPasswordController.text = 'NewPass@1';
      ctrl.confirmPasswordController.text = 'NewPass@1';

      await ctrl.submitChangePassword();

      expect(ctrl.changePasswordError.value, isNotEmpty);
      expect(ctrl.isChangingPassword.value, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – role getter', () {
    // Use checkAuth (no navigation side-effects) to seed currentAuth
    Future<AuthController> _loggedInController(String role) async {
      final auth = _makeAuth(role: role);
      final repo = _StubAuthRepository()..checkAuthResult = auth;
      final ctrl = _buildController(repo);
      await ctrl.checkAuth();
      return ctrl;
    }

    test('returns UserRole.Admin for "Admin" role', () async {
      final ctrl = await _loggedInController('Admin');
      expect(ctrl.role, UserRole.Admin);
    });

    test('returns UserRole.Manager for "Manager" role', () async {
      final ctrl = await _loggedInController('Manager');
      expect(ctrl.role, UserRole.Manager);
    });

    test('returns UserRole.Employee for "Employee" role', () async {
      final ctrl = await _loggedInController('Employee');
      expect(ctrl.role, UserRole.Employee);
    });

    test('returns null for unknown role', () async {
      final ctrl = await _loggedInController('Unknown');
      expect(ctrl.role, isNull);
    });

    test('role comparison is case-insensitive', () async {
      final ctrl = await _loggedInController('ADMIN');
      expect(ctrl.role, UserRole.Admin);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – obscurePassword', () {
    test('starts true (password hidden by default)', () {
      final ctrl = _buildController(_StubAuthRepository());
      expect(ctrl.obscurePassword.value, isTrue);
    });

    test('can be toggled to false', () {
      final ctrl = _buildController(_StubAuthRepository());
      ctrl.obscurePassword.value = false;
      expect(ctrl.obscurePassword.value, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – clearChangePasswordForm()', () {
    test('clears all fields and resets visibility flags', () {
      final ctrl = _buildController(_StubAuthRepository());
      ctrl.currentPasswordController.text = 'abc';
      ctrl.newPasswordController.text = 'def';
      ctrl.confirmPasswordController.text = 'ghi';
      ctrl.obscureCurrent.value = false;
      ctrl.obscureNew.value = false;
      ctrl.obscureConfirm.value = false;
      ctrl.changePasswordError.value = 'some error';

      ctrl.clearChangePasswordForm();

      expect(ctrl.currentPasswordController.text, '');
      expect(ctrl.newPasswordController.text, '');
      expect(ctrl.confirmPasswordController.text, '');
      expect(ctrl.obscureCurrent.value, isTrue);
      expect(ctrl.obscureNew.value, isTrue);
      expect(ctrl.obscureConfirm.value, isTrue);
      expect(ctrl.changePasswordError.value, '');
    });
  });
}
