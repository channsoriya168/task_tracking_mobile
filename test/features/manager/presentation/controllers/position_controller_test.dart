import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';

// ── Stubs ──────────────────────────────────────────────────────

class _StubImageService extends ImageService {
  @override
  Future<File?> pickImage(ImageSource source) async => null;

  @override
  Future<File?> compressImage(File file) async => null;
}

class _StubTaskGroupRepository implements TaskGroupRepository {
  final List<TaskGroup> _seed;

  _StubTaskGroupRepository(this._seed);

  @override
  Future<List<TaskGroup>> getAll() async => List.from(_seed);

  @override
  Future<TaskGroup> getById(String id) async =>
      _seed.firstWhere((t) => t.id == id);

  @override
  Future<TaskGroup> create({
    required String name,
    String? color,
    String? description,
  }) async =>
      TaskGroup(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
      );

  @override
  Future<TaskGroup> update(
    String id, {
    required String name,
    String? color,
    String? description,
  }) async {
    final tg = _seed.firstWhere((t) => t.id == id);
    return tg.copyWith(name: name);
  }

  @override
  Future<void> delete(String id) async {
    _seed.removeWhere((t) => t.id == id);
  }
}

// ── Mock data ──────────────────────────────────────────────────

List<TaskGroup> _mockTaskGroups() => [
      TaskGroup(id: 'p1', name: 'Engineering', color: const Color(0xFF6C63FF)),
      TaskGroup(id: 'p2', name: 'Design', color: const Color(0xFF2ED573)),
      TaskGroup(id: 'p3', name: 'Marketing', color: const Color(0xFFFF6B6B)),
      TaskGroup(id: 'p4', name: 'Finance', color: const Color(0xFFFFBE76)),
    ];

// ── Helpers ────────────────────────────────────────────────────

Widget _appWith(Widget child) => GetMaterialApp(home: Scaffold(body: child));

Future<TaskGroupController> _setupControllers() async {
  Get.reset();
  Get.testMode = true;
  final stub = _StubTaskGroupRepository(_mockTaskGroups());
  Get.put<PickAndCompressImageUseCase>(
    PickAndCompressImageUseCase(_StubImageService()),
  );
  final ctrl = Get.put<TaskGroupController>(
    TaskGroupController(
      GetAllTaskGroupsUseCase(stub),
      CreateTaskGroupUseCase(stub),
    ),
  );
  Get.put<EmployeeController>(EmployeeController());
  // Ensure async fetch completes
  await ctrl.fetchTaskGroups();
  return ctrl;
}

void main() {
  tearDown(() => Get.reset());

  // ── Initial state ──────────────────────────────────────────

  group('TaskGroupController – initial state', () {
    test('task groups loaded from use case on init', () async {
      final ctrl = await _setupControllers();
      expect(ctrl.taskGroups, isNotEmpty);
      expect(ctrl.taskGroups.length, _mockTaskGroups().length);
    });
  });

  // ── findPosition ───────────────────────────────────────────

  group('TaskGroupController – findPosition', () {
    test('returns task group for known id', () async {
      final ctrl = await _setupControllers();
      final tg = ctrl.taskGroups.first;
      expect(ctrl.findPosition(tg.id), isNotNull);
      expect(ctrl.findPosition(tg.id)!.name, tg.name);
    });

    test('returns null for unknown id', () async {
      final ctrl = await _setupControllers();
      expect(ctrl.findPosition('unknown_id'), isNull);
    });
  });

  // ── generateId ─────────────────────────────────────────────

  group('TaskGroupController – generateId', () {
    test('returns a non-empty string', () async {
      final ctrl = await _setupControllers();
      expect(ctrl.generateId(), isNotEmpty);
    });
  });

  // ── createTaskGroup ────────────────────────────────────────

  group('TaskGroupController – createTaskGroup', () {
    testWidgets('appends task group to the list', (tester) async {
      final ctrl = await _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final before = ctrl.taskGroups.length;

      final success = await ctrl.createTaskGroup(
        name: 'QA',
        color: const Color(0xFF000000),
      );
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(success, isTrue);
      expect(ctrl.taskGroups.length, before + 1);
      expect(ctrl.taskGroups.any((p) => p.name == 'QA'), isTrue);
    });
  });

  // ── updateTaskGroup ────────────────────────────────────────

  group('TaskGroupController – updateTaskGroup', () {
    testWidgets('updates an existing task group', (tester) async {
      final ctrl = await _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final original = ctrl.taskGroups.first;

      ctrl.updateTaskGroup(original.copyWith(name: 'Updated'));
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      final found = ctrl.taskGroups.firstWhere((p) => p.id == original.id);
      expect(found.name, 'Updated');
    });

    testWidgets('does nothing for unknown id', (tester) async {
      final ctrl = await _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final before = ctrl.taskGroups.length;

      ctrl.updateTaskGroup(
        TaskGroup(id: 'ghost_p', name: 'Ghost'),
      );
      await tester.pump(Duration.zero);

      expect(ctrl.taskGroups.length, before);
    });
  });

  // ── deleteTaskGroup ────────────────────────────────────────

  group('TaskGroupController – deleteTaskGroup', () {
    testWidgets('removes task group from list', (tester) async {
      final ctrl = await _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final target = ctrl.taskGroups.first;

      ctrl.deleteTaskGroup(target.id);
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(ctrl.taskGroups.any((p) => p.id == target.id), isFalse);
    });

    testWidgets('also removes employees assigned to that task group', (tester) async {
      final ctrl = await _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final empCtrl = Get.find<EmployeeController>();

      // Find a task group that has employees
      final pos = ctrl.taskGroups.firstWhere(
        (p) => empCtrl.employees.any((e) => e.positionId == p.id),
      );
      ctrl.deleteTaskGroup(pos.id);
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(empCtrl.employees.any((e) => e.positionId == pos.id), isFalse);
    });

    testWidgets('does nothing for unknown id', (tester) async {
      final ctrl = await _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final before = ctrl.taskGroups.length;

      ctrl.deleteTaskGroup('no_such_id');
      await tester.pump(Duration.zero);

      expect(ctrl.taskGroups.length, before);
    });
  });
}
