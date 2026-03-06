import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';

// ── Stubs ──────────────────────────────────────────────────────
class _StubImageService extends ImageService {
  @override
  Future<File?> pickImage(ImageSource source) async => null;

  @override
  Future<File?> compressImage(File file) async => null;
}

EmployeeController _buildController() {
  Get.reset();
  Get.testMode = true;

  Get.put<PositionController>(PositionController());
  Get.put<PickAndCompressImageUseCase>(
    PickAndCompressImageUseCase(_StubImageService()),
  );

  return Get.put<EmployeeController>(EmployeeController());
}

void main() {
  tearDown(() => Get.reset());

  group('EmployeeController – initial state', () {
    test('employees populated from mock data on init', () {
      final ctrl = _buildController();
      expect(ctrl.employees, isNotEmpty);
      expect(ctrl.employees.length, kMockEmployees.length);
    });

    test('searchQuery starts empty', () {
      final ctrl = _buildController();
      expect(ctrl.searchQuery.value, '');
    });

    test('filteredEmployees returns all when query is empty', () {
      final ctrl = _buildController();
      expect(ctrl.filteredEmployees.length, ctrl.employees.length);
    });
  });

  group('EmployeeController – search', () {
    test('filteredEmployees filters by name (case-insensitive)', () {
      final ctrl = _buildController();
      ctrl.searchQuery.value = 'alice';
      final results = ctrl.filteredEmployees;
      expect(results.every((e) => e.name.toLowerCase().contains('alice')), isTrue);
    });

    test('filteredEmployees filters by email', () {
      final ctrl = _buildController();
      ctrl.searchQuery.value = 'bob@company';
      final results = ctrl.filteredEmployees;
      expect(results.every((e) => e.email.toLowerCase().contains('bob@company')), isTrue);
    });

    test('filteredEmployees returns empty when no match', () {
      final ctrl = _buildController();
      ctrl.searchQuery.value = 'zzznomatch';
      expect(ctrl.filteredEmployees, isEmpty);
    });
  });

  group('EmployeeController – CRUD', () {
    test('addEmployee appends to the list', () {
      final ctrl = _buildController();
      final before = ctrl.employees.length;
      ctrl.addEmployee(
        const Employee(id: 'new1', name: 'New Guy', email: 'new@test.com', positionId: 'p1'),
      );
      expect(ctrl.employees.length, before + 1);
      expect(ctrl.employees.any((e) => e.id == 'new1'), isTrue);
    });

    test('updateEmployee replaces the existing record', () {
      final ctrl = _buildController();
      final original = ctrl.employees.first;
      final updated = original.copyWith(name: 'Updated Name');
      ctrl.updateEmployee(updated);
      final found = ctrl.employees.firstWhere((e) => e.id == original.id);
      expect(found.name, 'Updated Name');
    });

    test('updateEmployee does nothing when id not found', () {
      final ctrl = _buildController();
      final before = ctrl.employees.length;
      ctrl.updateEmployee(
        const Employee(id: 'ghost', name: 'Ghost', email: 'g@g.com', positionId: 'p1'),
      );
      expect(ctrl.employees.length, before);
    });

    test('deleteEmployee removes the record', () {
      final ctrl = _buildController();
      final target = ctrl.employees.first;
      ctrl.deleteEmployee(target.id);
      expect(ctrl.employees.any((e) => e.id == target.id), isFalse);
    });

    test('deleteEmployee does nothing for unknown id', () {
      final ctrl = _buildController();
      final before = ctrl.employees.length;
      ctrl.deleteEmployee('non_existent_id');
      expect(ctrl.employees.length, before);
    });
  });

  group('EmployeeController – helpers', () {
    test('employeesByPosition returns matching employees', () {
      final ctrl = _buildController();
      final positionId = ctrl.employees.first.positionId;
      final result = ctrl.employeesByPosition(positionId);
      expect(result.every((e) => e.positionId == positionId), isTrue);
    });

    test('employeeCountByPosition counts correctly', () {
      final ctrl = _buildController();
      final positionId = ctrl.employees.first.positionId;
      final expected = ctrl.employees.where((e) => e.positionId == positionId).length;
      expect(ctrl.employeeCountByPosition(positionId), expected);
    });

    test('findPosition returns position when it exists', () {
      final ctrl = _buildController();
      final posCtrl = Get.find<PositionController>();
      final pos = posCtrl.positions.first;
      expect(ctrl.findPosition(pos.id), isNotNull);
      expect(ctrl.findPosition(pos.id)!.id, pos.id);
    });

    test('findPosition returns null for unknown id', () {
      final ctrl = _buildController();
      expect(ctrl.findPosition('no_such_position'), isNull);
    });

    test('generateId returns a non-empty string', () {
      final ctrl = _buildController();
      expect(ctrl.generateId(), isNotEmpty);
    });
  });

  group('EmployeeController – form state', () {
    test('initDialogForm sets fields from existing employee', () {
      final ctrl = _buildController();
      final emp = ctrl.employees.first;
      ctrl.initDialogForm(emp, null);

      expect(ctrl.nameCtrl.text, emp.name);
      expect(ctrl.emailCtrl.text, emp.email);
      expect(ctrl.formPositionId.value, emp.positionId);
    });

    test('initDialogForm uses preselectedPositionId when no existing employee', () {
      final ctrl = _buildController();
      ctrl.initDialogForm(null, 'p2');
      expect(ctrl.formPositionId.value, 'p2');
    });

    test('saveEmployee does nothing when name is empty', () {
      final ctrl = _buildController();
      ctrl.initDialogForm(null, null);
      final before = ctrl.employees.length;
      ctrl.nameCtrl.text = '';
      ctrl.emailCtrl.text = 'some@email.com';
      ctrl.saveEmployee();
      expect(ctrl.employees.length, before);
    });

    test('saveEmployee does nothing when email is empty', () {
      final ctrl = _buildController();
      ctrl.initDialogForm(null, 'p1');
      final before = ctrl.employees.length;
      ctrl.nameCtrl.text = 'Valid Name';
      ctrl.emailCtrl.text = '';
      ctrl.saveEmployee();
      expect(ctrl.employees.length, before);
    });

    test('saveEmployee adds new employee when all fields filled', () {
      final ctrl = _buildController();
      ctrl.initDialogForm(null, 'p1');
      final before = ctrl.employees.length;
      ctrl.nameCtrl.text = 'Test Person';
      ctrl.emailCtrl.text = 'test@test.com';
      ctrl.saveEmployee();
      expect(ctrl.employees.length, before + 1);
    });

    test('saveEmployee updates existing employee', () {
      final ctrl = _buildController();
      final emp = ctrl.employees.first;
      ctrl.initDialogForm(emp, null);
      ctrl.nameCtrl.text = 'Changed Name';
      ctrl.saveEmployee();
      final found = ctrl.employees.firstWhere((e) => e.id == emp.id);
      expect(found.name, 'Changed Name');
    });
  });
}