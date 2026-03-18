import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/reset_employee_password_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/update_employee_usecase.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';

// ── Stub repository ──────────────────────────────────────────────────────────

class _StubEmployeeRepository implements EmployeeRepository {
  List<Employee> fetchResult = [];
  Object? fetchError;

  Employee? createResult;
  Object? createError;

  Employee? updateResult;
  Object? updateError;

  Object? deleteError;
  bool deleteCalled = false;
  String? deletedId;

  Object? resetError;
  bool resetCalled = false;

  @override
  Future<List<Employee>> fetchEmployees({String? name, String? groupId}) async {
    if (fetchError != null) throw fetchError!;
    return fetchResult;
  }

  @override
  Future<Employee> fetchEmployeeById(String id) async => fetchResult.first;

  @override
  Future<Employee> createEmployee({
    required String fullName,
    String? email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    List<String>? groupIds,
    String? profileImagePath,
    String? role,
  }) async {
    if (createError != null) throw createError!;
    return createResult!;
  }

  @override
  Future<Employee> updateEmployee(
    String id, {
    required String fullName,
    String? email,
    String? phone,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    List<String>? groupIds,
    String? profileImagePath,
    bool removeProfileImage = false,
    String? password,
    String? confirmPassword,
    String? role,
  }) async {
    if (updateError != null) throw updateError!;
    return updateResult!;
  }

  @override
  Future<void> deleteEmployee(String id) async {
    deleteCalled = true;
    deletedId = id;
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<void> resetPassword({
    required String employeeId,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    resetCalled = true;
    if (resetError != null) throw resetError!;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Employee _makeEmployee({
  String id = 'e1',
  String fullName = 'Alice',
  String email = 'alice@example.com',
  String? groupId,
}) =>
    Employee(
      id: id,
      fullName: fullName,
      email: email,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      taskGroups: groupId != null
          ? [
              EmployeeTaskGroup(
                groupId: groupId,
                groupName: 'Group',
                groupColor: const Color(0xFF3B82F6),
                role: 0,
                joinedAt: DateTime(2024, 1, 1),
              ),
            ]
          : [],
    );

DioException _makeDioError(int statusCode, {Map<String, dynamic>? data}) =>
    DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: statusCode,
        data: data,
      ),
      type: DioExceptionType.badResponse,
    );

EmployeeController _buildController(_StubEmployeeRepository repo) {
  Get.reset();
  Get.testMode = true;
  return Get.put<EmployeeController>(
    EmployeeController(
      repo,
      CreateEmployeeUsecase(repo),
      UpdateEmployeeUsecase(repo),
      ResetEmployeePasswordUsecase(repo),
    ),
  );
}

/// Pumps the event queue so that onInit()'s async fetchEmployees() completes.
Future<void> _pump() => Future<void>.delayed(Duration.zero);

/// Runs [fn] in a guarded zone that absorbs async zone errors emitted by
/// GetX's snackbar / navigation machinery (which requires a real widget tree).
Future<void> _guardedRun(Future<void> Function() fn) async {
  final completer = Completer<void>();
  runZonedGuarded(() async {
    try {
      await fn();
    } finally {
      if (!completer.isCompleted) completer.complete();
    }
  }, (_, __) {
    if (!completer.isCompleted) completer.complete();
  });
  await completer.future;
}

void main() {
  tearDown(() => Get.reset());

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – initial state', () {
    test('searchQuery starts empty', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.searchQuery.value, '');
    });

    test('selectedTaskGroupId starts empty', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.selectedTaskGroupId.value, '');
    });

    test('selectedRole starts as Employee', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.selectedRole.value, 'Employee');
    });

    test('fieldErrors starts empty', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.fieldErrors, isEmpty);
    });

    test('isSaving starts false', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.isSaving.value, isFalse);
    });

    test('isEditMode starts false', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.isEditMode.value, isFalse);
    });

    test('isResettingPassword starts false', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.isResettingPassword.value, isFalse);
    });

    test('canSave is false when neither dob nor group is set', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      expect(ctrl.canSave, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – fetchEmployees()', () {
    test('populates employees list on success', () async {
      final repo = _StubEmployeeRepository()
        ..fetchResult = [_makeEmployee()];
      final ctrl = _buildController(repo);
      await _pump();
      expect(ctrl.employees, hasLength(1));
      expect(ctrl.employees.first.id, 'e1');
    });

    test('isLoading resets to false after successful fetch', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      await _pump();
      expect(ctrl.isLoading.value, isFalse);
    });

    test('isLoading resets to false on fetch failure', () async {
      final repo = _StubEmployeeRepository()
        ..fetchError = Exception('Network error');
      late EmployeeController ctrl;
      await _guardedRun(() async {
        ctrl = _buildController(repo);
        await _pump();
      });
      expect(ctrl.isLoading.value, isFalse);
    });

    test('employees remains empty when fetch fails', () async {
      final repo = _StubEmployeeRepository()
        ..fetchError = Exception('Network error');
      late EmployeeController ctrl;
      await _guardedRun(() async {
        ctrl = _buildController(repo);
        await _pump();
      });
      expect(ctrl.employees, isEmpty);
    });

    test('replaces employees list on second fetch', () async {
      final repo = _StubEmployeeRepository()
        ..fetchResult = [_makeEmployee(id: 'e1'), _makeEmployee(id: 'e2')];
      final ctrl = _buildController(repo);
      await _pump();
      expect(ctrl.employees, hasLength(2));

      repo.fetchResult = [_makeEmployee(id: 'e1')];
      await ctrl.fetchEmployees();
      expect(ctrl.employees, hasLength(1));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – filteredEmployees', () {
    late _StubEmployeeRepository repo;
    late EmployeeController ctrl;

    setUp(() async {
      repo = _StubEmployeeRepository()
        ..fetchResult = [
          _makeEmployee(id: 'e1', fullName: 'Alice Smith', email: 'alice@example.com', groupId: 'g1'),
          _makeEmployee(id: 'e2', fullName: 'Bob Jones', email: 'bob@example.com', groupId: 'g2'),
          _makeEmployee(id: 'e3', fullName: 'Charlie', email: 'charlie@example.com', groupId: 'g1'),
        ];
      ctrl = _buildController(repo);
      await _pump();
    });

    test('returns all employees when no filters are set', () {
      expect(ctrl.filteredEmployees, hasLength(3));
    });

    test('filters by name (case-insensitive)', () {
      ctrl.searchQuery.value = 'alice';
      expect(ctrl.filteredEmployees, hasLength(1));
      expect(ctrl.filteredEmployees.first.id, 'e1');
    });

    test('filters by email', () {
      ctrl.searchQuery.value = 'bob@';
      expect(ctrl.filteredEmployees, hasLength(1));
      expect(ctrl.filteredEmployees.first.id, 'e2');
    });

    test('filters by task group id', () {
      ctrl.selectedTaskGroupId.value = 'g1';
      expect(ctrl.filteredEmployees, hasLength(2));
      expect(ctrl.filteredEmployees.map((e) => e.id), containsAll(['e1', 'e3']));
    });

    test('applies both search and group filter together', () {
      ctrl.selectedTaskGroupId.value = 'g1';
      ctrl.searchQuery.value = 'alice';
      expect(ctrl.filteredEmployees, hasLength(1));
      expect(ctrl.filteredEmployees.first.id, 'e1');
    });

    test('returns empty list when no employee matches query', () {
      ctrl.searchQuery.value = 'nonexistent_xyz';
      expect(ctrl.filteredEmployees, isEmpty);
    });

    test('returns empty list when group filter matches no employee', () {
      ctrl.selectedTaskGroupId.value = 'g99';
      expect(ctrl.filteredEmployees, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – deleteEmployee()', () {
    test('removes the employee from the list on success', () async {
      final repo = _StubEmployeeRepository()
        ..fetchResult = [_makeEmployee(id: 'e1'), _makeEmployee(id: 'e2')];
      final ctrl = _buildController(repo);
      await _pump();

      await _guardedRun(() => ctrl.deleteEmployee('e1'));

      expect(ctrl.employees.any((e) => e.id == 'e1'), isFalse);
      expect(ctrl.employees, hasLength(1));
    });

    test('calls repository deleteEmployee with the correct id', () async {
      final repo = _StubEmployeeRepository()
        ..fetchResult = [_makeEmployee(id: 'e1')];
      final ctrl = _buildController(repo);
      await _pump();

      await _guardedRun(() => ctrl.deleteEmployee('e1'));

      expect(repo.deleteCalled, isTrue);
      expect(repo.deletedId, 'e1');
    });

    test('keeps employee list unchanged on delete failure', () async {
      final repo = _StubEmployeeRepository()
        ..fetchResult = [_makeEmployee(id: 'e1')]
        ..deleteError = Exception('Server error');
      final ctrl = _buildController(repo);
      await _pump();

      await _guardedRun(() => ctrl.deleteEmployee('e1'));

      expect(ctrl.employees, hasLength(1));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – selectGroup()', () {
    test('sets selectedGroupId when a group is selected', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.selectGroup('g1');
      expect(ctrl.selectedGroupId.value, 'g1');
    });

    test('deselects the group when the same group is selected again', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.selectGroup('g1');
      ctrl.selectGroup('g1');
      expect(ctrl.selectedGroupId.value, isNull);
    });

    test('switches to a different group', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.selectGroup('g1');
      ctrl.selectGroup('g2');
      expect(ctrl.selectedGroupId.value, 'g2');
    });

    test('clears taskGroup field error when a valid group is selected', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.fieldErrors['taskGroup'] = 'Please select a task group.';
      ctrl.selectGroup('g1');
      expect(ctrl.fieldErrors.containsKey('taskGroup'), isFalse);
    });

    test('does not clear taskGroup error when group is deselected', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.selectGroup('g1'); // select
      ctrl.fieldErrors['taskGroup'] = 'Please select a task group.';
      ctrl.selectGroup('g1'); // deselect
      expect(ctrl.fieldErrors.containsKey('taskGroup'), isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – canSave', () {
    test('returns false when formDob is null', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.selectedGroupId.value = 'g1';
      expect(ctrl.canSave, isFalse);
    });

    test('returns false when selectedGroupId is null', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.formDob.value = DateTime(1990, 1, 1);
      expect(ctrl.canSave, isFalse);
    });

    test('returns true when both dob and groupId are set', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.formDob.value = DateTime(1990, 1, 1);
      ctrl.selectedGroupId.value = 'g1';
      expect(ctrl.canSave, isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – openResetPasswordForm()', () {
    test('clears form fields and resets visibility flags', () {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.resetPasswordCtrl.text = 'old_pass';
      ctrl.resetConfirmPasswordCtrl.text = 'old_confirm';
      ctrl.showResetPassword.value = true;
      ctrl.showResetConfirmPassword.value = true;
      ctrl.resetPasswordErrors['newPassword'] = 'some error';

      ctrl.openResetPasswordForm();

      expect(ctrl.resetPasswordCtrl.text, '');
      expect(ctrl.resetConfirmPasswordCtrl.text, '');
      expect(ctrl.showResetPassword.value, isFalse);
      expect(ctrl.showResetConfirmPassword.value, isFalse);
      expect(ctrl.resetPasswordErrors, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – resetPasswordForEmployee()', () {
    test('sets newPassword error when password is empty', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      await ctrl.resetPasswordForEmployee('e1');
      expect(ctrl.resetPasswordErrors.containsKey('newPassword'), isTrue);
    });

    test('sets newPassword error for weak password', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.resetPasswordCtrl.text = 'weak';
      ctrl.resetConfirmPasswordCtrl.text = 'weak';
      await ctrl.resetPasswordForEmployee('e1');
      expect(ctrl.resetPasswordErrors.containsKey('newPassword'), isTrue);
    });

    test('sets confirmPassword error when passwords do not match', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.resetPasswordCtrl.text = 'StrongPass@1';
      ctrl.resetConfirmPasswordCtrl.text = 'DifferentPass@2';
      await ctrl.resetPasswordForEmployee('e1');
      expect(
        ctrl.resetPasswordErrors['confirmPassword'],
        'Passwords do not match.',
      );
    });

    test('sets confirmPassword error when confirm field is empty', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.resetPasswordCtrl.text = 'StrongPass@1';
      ctrl.resetConfirmPasswordCtrl.text = '';
      await ctrl.resetPasswordForEmployee('e1');
      expect(ctrl.resetPasswordErrors.containsKey('confirmPassword'), isTrue);
    });

    test('does not call repository when validation fails', () async {
      final repo = _StubEmployeeRepository();
      final ctrl = _buildController(repo);
      ctrl.resetPasswordCtrl.text = 'weak';
      ctrl.resetConfirmPasswordCtrl.text = 'weak';
      await ctrl.resetPasswordForEmployee('e1');
      expect(repo.resetCalled, isFalse);
    });

    test('calls repository and clears form on success', () async {
      final repo = _StubEmployeeRepository();
      final ctrl = _buildController(repo);
      ctrl.resetPasswordCtrl.text = 'StrongPass@1';
      ctrl.resetConfirmPasswordCtrl.text = 'StrongPass@1';

      await _guardedRun(() => ctrl.resetPasswordForEmployee('e1'));

      expect(repo.resetCalled, isTrue);
      expect(ctrl.resetPasswordCtrl.text, '');
      expect(ctrl.resetConfirmPasswordCtrl.text, '');
      expect(ctrl.isResettingPassword.value, isFalse);
    });

    test('resets isResettingPassword to false on repository failure', () async {
      final repo = _StubEmployeeRepository()
        ..resetError = Exception('Server error');
      final ctrl = _buildController(repo);
      ctrl.resetPasswordCtrl.text = 'StrongPass@1';
      ctrl.resetConfirmPasswordCtrl.text = 'StrongPass@1';

      await _guardedRun(() => ctrl.resetPasswordForEmployee('e1'));

      expect(ctrl.isResettingPassword.value, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – save() create validation', () {
    void _fillValidCreateForm(EmployeeController ctrl) {
      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990, 1, 1);
      ctrl.selectedGroupId.value = 'g1';
    }

    test('sets fullName error when name is empty', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('fullName'), isTrue);
    });

    test('sets phone error for invalid phone number', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '123'; // too short
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('phone'), isTrue);
    });

    test('sets email error for invalid email format', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.nameCtrl.text = 'Alice';
      ctrl.emailCtrl.text = 'not-an-email';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('email'), isTrue);
    });

    test('sets password error for weak password', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'weak';
      ctrl.confirmPasswordCtrl.text = 'weak';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('password'), isTrue);
    });

    test('sets confirmPassword error when passwords do not match', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'DifferentPass@2';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('confirmPassword'), isTrue);
    });

    test('sets dob error when date of birth is missing', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.selectedGroupId.value = 'g1';
      // formDob is null

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('dob'), isTrue);
    });

    test('sets taskGroup error when group is not selected', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990);
      // selectedGroupId is null

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('taskGroup'), isTrue);
    });

    test('does not call repository when validation fails', () async {
      final repo = _StubEmployeeRepository();
      final ctrl = _buildController(repo);
      // All fields empty

      await ctrl.save();

      expect(ctrl.fieldErrors.isNotEmpty, isTrue);
      expect(ctrl.isSaving.value, isFalse);
    });

    test('clears field errors at the start of each save attempt', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.fieldErrors['fullName'] = 'old error';

      // Trigger save with a different missing field (phone)
      ctrl.nameCtrl.text = 'Alice'; // fix fullName
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';
      // phone is still empty

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('fullName'), isFalse);
      expect(ctrl.fieldErrors.containsKey('phone'), isTrue);
    });

    test('calls createEmployee and resets isSaving on success', () async {
      final employee = _makeEmployee();
      final repo = _StubEmployeeRepository()
        ..createResult = employee
        ..fetchResult = [employee];
      final ctrl = _buildController(repo);
      await _pump();

      _fillValidCreateForm(ctrl);
      await _guardedRun(() => ctrl.save());

      expect(ctrl.isSaving.value, isFalse);
      expect(ctrl.fieldErrors, isEmpty);
    });

    test('maps server DioException validation errors to fieldErrors', () async {
      final repo = _StubEmployeeRepository()
        ..createError = _makeDioError(422, data: {
          'errors': {
            'FullName': ['Name is already taken.'],
            'Email': ['Email already exists.'],
          },
        });
      final ctrl = _buildController(repo);
      await _pump();

      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors['fullName'], 'Name is already taken.');
      expect(ctrl.fieldErrors['email'], 'Email already exists.');
      expect(ctrl.isSaving.value, isFalse);
    });

    test('uses first error message when server returns list of errors', () async {
      final repo = _StubEmployeeRepository()
        ..createError = _makeDioError(422, data: {
          'errors': {
            'Password': ['Too short.', 'Needs special character.'],
          },
        });
      final ctrl = _buildController(repo);
      await _pump();

      ctrl.nameCtrl.text = 'Alice';
      ctrl.phoneCtrl.text = '884311016';
      ctrl.passwordCtrl.text = 'StrongPass@1';
      ctrl.confirmPasswordCtrl.text = 'StrongPass@1';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors['password'], 'Too short.');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeController – save() edit validation', () {
    test('sets fullName error when name is empty in edit mode', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.isEditMode.value = true;
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';
      // nameCtrl is empty

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('fullName'), isTrue);
    });

    test('sets password error when edit password is too weak', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.isEditMode.value = true;
      ctrl.nameCtrl.text = 'Alice';
      ctrl.passwordCtrl.text = 'weak';
      ctrl.confirmPasswordCtrl.text = 'weak';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('password'), isTrue);
    });

    test('does not set password error when password field is empty in edit mode', () async {
      // In edit mode, empty password means "keep existing password" — skip validation
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.isEditMode.value = true;
      ctrl.nameCtrl.text = 'Alice';
      ctrl.formDob.value = DateTime(1990);
      ctrl.selectedGroupId.value = 'g1';
      // passwordCtrl is empty → skip password validation in edit mode

      await _guardedRun(() => ctrl.save());

      expect(ctrl.fieldErrors.containsKey('password'), isFalse);
    });

    test('does not call repository when edit validation fails', () async {
      final repo = _StubEmployeeRepository();
      final ctrl = _buildController(repo);
      ctrl.isEditMode.value = true;
      // name is empty → validation fails

      await ctrl.save();

      expect(ctrl.isSaving.value, isFalse);
      expect(ctrl.fieldErrors.containsKey('fullName'), isTrue);
    });

    test('sets dob error when dob is missing in edit mode', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.isEditMode.value = true;
      ctrl.nameCtrl.text = 'Alice';
      ctrl.selectedGroupId.value = 'g1';
      // formDob is null

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('dob'), isTrue);
    });

    test('sets taskGroup error when group is missing in edit mode', () async {
      final ctrl = _buildController(_StubEmployeeRepository());
      ctrl.isEditMode.value = true;
      ctrl.nameCtrl.text = 'Alice';
      ctrl.formDob.value = DateTime(1990);
      // selectedGroupId is null

      await ctrl.save();

      expect(ctrl.fieldErrors.containsKey('taskGroup'), isTrue);
    });
  });
}
