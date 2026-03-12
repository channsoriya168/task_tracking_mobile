import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

// ── Stub repository ─────────────────────────────────────────────────────────

class _StubAuthRepository implements AuthRepository {
  Auth? loginResult;
  Object? loginError;
  Auth? sessionResult;
  bool logoutCalled = false;

  @override
  Future<Auth> login(String phoneNumber, String password) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<Auth?> restoreSession() async => sessionResult;

  @override
  Future<void> logout() async => logoutCalled = true;
}

// ── JWT helper ───────────────────────────────────────────────────────────────

String _makeJwt({required int exp}) {
  const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
  final payloadEncoded =
      base64Url.encode(utf8.encode('{"sub":"u1","exp":$exp}')).replaceAll('=', '');
  return '$header.$payloadEncoded.sig';
}

final int _futureExp =
    (DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch / 1000)
        .floor();

Auth _makeAuth({String role = 'Manager'}) => Auth(
      userId: 'u1',
      fullName: 'Alice Smith',
      phoneNumber: '+85512345678',
      roles: [role],
      accessToken: _makeJwt(exp: _futureExp),
      refreshToken: 'rt',
      accessTokenExpiration:
          DateTime.fromMillisecondsSinceEpoch(_futureExp * 1000),
    );

// ── Test setup ───────────────────────────────────────────────────────────────

AuthController _buildController(_StubAuthRepository repo) {
  Get.reset();
  Get.testMode = true;

  Get.put<AuthRepository>(repo);
  Get.put<NavigationController>(NavigationController());

  return Get.put<AuthController>(AuthController());
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
    test('sets isAuthenticated to true on success', () async {
      final repo = _StubAuthRepository()..loginResult = _makeAuth();
      final ctrl = _buildController(repo);

      ctrl.phoneController.text = '+85512345678';
      ctrl.passwordController.text = 'secret';
      await ctrl.login();

      expect(ctrl.isAuthenticated, isTrue);
      expect(ctrl.currentAuth.value, isNotNull);
    });

    test('isLoading resets to false after successful login', () async {
      final repo = _StubAuthRepository()..loginResult = _makeAuth();
      final ctrl = _buildController(repo);

      await ctrl.login();

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

    test('clears previous errorMessage on new login attempt', () async {
      final repo = _StubAuthRepository()
        ..loginError = Exception('first error');
      final ctrl = _buildController(repo);

      await ctrl.login();
      expect(ctrl.errorMessage.value, isNotEmpty);

      // Now succeed.
      repo
        ..loginError = null
        ..loginResult = _makeAuth();
      await ctrl.login();

      expect(ctrl.errorMessage.value, '');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – restoreSession()', () {
    test('returns true and sets currentAuth when session exists', () async {
      final auth = _makeAuth();
      final repo = _StubAuthRepository()..sessionResult = auth;
      final ctrl = _buildController(repo);

      final result = await ctrl.restoreSession();

      expect(result, isTrue);
      expect(ctrl.currentAuth.value, auth);
    });

    test('returns false and leaves currentAuth null when no session', () async {
      final repo = _StubAuthRepository()..sessionResult = null;
      final ctrl = _buildController(repo);

      final result = await ctrl.restoreSession();

      expect(result, isFalse);
      expect(ctrl.currentAuth.value, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – logout()', () {
    test('clears currentAuth after logout', () async {
      final repo = _StubAuthRepository()..loginResult = _makeAuth();
      final ctrl = _buildController(repo);

      await ctrl.login();
      expect(ctrl.isAuthenticated, isTrue);

      await ctrl.logout();

      expect(ctrl.currentAuth.value, isNull);
      expect(ctrl.isAuthenticated, isFalse);
    });

    test('calls repository logout', () async {
      final repo = _StubAuthRepository()..loginResult = _makeAuth();
      final ctrl = _buildController(repo);

      await ctrl.login();
      await ctrl.logout();

      expect(repo.logoutCalled, isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthController – role getter', () {
    Future<AuthController> _loggedInController(String role) async {
      final repo = _StubAuthRepository()..loginResult = _makeAuth(role: role);
      final ctrl = _buildController(repo);
      await ctrl.login();
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
}
