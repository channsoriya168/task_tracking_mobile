import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';

class _StubImageService extends ImageService {
  @override
  Future<File?> pickImage(ImageSource source) async => null;

  @override
  Future<File?> compressImage(File file) async => null;
}

// ── Helpers ───────────────────────────────────────────────────

/// Wraps the test in a GetMaterialApp so that Get.snackbar has an overlay.
Widget _appWith(Widget child) => GetMaterialApp(home: Scaffold(body: child));

void _setupControllers() {
  Get.reset();
  Get.testMode = true;
  Get.put<PickAndCompressImageUseCase>(
    PickAndCompressImageUseCase(_StubImageService()),
  );
  Get.put<PositionController>(PositionController());
  Get.put<EmployeeController>(EmployeeController());
}

void main() {
  tearDown(() => Get.reset());

  // ── Non-mutating tests (no snackbar) ─────────────────────────

  group('PositionController – initial state', () {
    test('positions loaded from mock data on init', () {
      _setupControllers();
      final ctrl = Get.find<PositionController>();
      expect(ctrl.positions, isNotEmpty);
      expect(ctrl.positions.length, kMockPositions.length);
    });
  });

  group('PositionController – findPosition', () {
    test('returns position for known id', () {
      _setupControllers();
      final ctrl = Get.find<PositionController>();
      final pos = ctrl.positions.first;
      expect(ctrl.findPosition(pos.id), isNotNull);
      expect(ctrl.findPosition(pos.id)!.name, pos.name);
    });

    test('returns null for unknown id', () {
      _setupControllers();
      final ctrl = Get.find<PositionController>();
      expect(ctrl.findPosition('unknown_id'), isNull);
    });
  });

  group('PositionController – generateId', () {
    test('returns a non-empty string', () {
      _setupControllers();
      final ctrl = Get.find<PositionController>();
      expect(ctrl.generateId(), isNotEmpty);
    });
  });

  // ── Mutating tests (trigger snackbar – need widget overlay) ──

  group('PositionController – addPosition', () {
    testWidgets('appends position to the list', (tester) async {
      _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final ctrl = Get.find<PositionController>();
      final before = ctrl.positions.length;

      ctrl.addPosition(
        const Position(id: 'new_p', name: 'QA', color: Color(0xFF000000)),
      );
      await tester.pump(Duration.zero);               // fire Future.delayed
      await tester.pump(const Duration(seconds: 3));  // snackbar auto-dismisses
      await tester.pumpAndSettle();                   // finish exit animation

      expect(ctrl.positions.length, before + 1);
      expect(ctrl.positions.any((p) => p.id == 'new_p'), isTrue);
    });
  });

  group('PositionController – updatePosition', () {
    testWidgets('updates an existing position', (tester) async {
      _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final ctrl = Get.find<PositionController>();
      final original = ctrl.positions.first;

      ctrl.updatePosition(original.copyWith(name: 'Updated'));
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      final found = ctrl.positions.firstWhere((p) => p.id == original.id);
      expect(found.name, 'Updated');
    });

    testWidgets('does nothing for unknown id', (tester) async {
      _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final ctrl = Get.find<PositionController>();
      final before = ctrl.positions.length;

      // updatePosition only snackbars on success; no snackbar for unknown id
      ctrl.updatePosition(
        const Position(id: 'ghost_p', name: 'Ghost', color: Color(0xFF000000)),
      );
      await tester.pump(Duration.zero);

      expect(ctrl.positions.length, before);
    });
  });

  group('PositionController – deletePosition', () {
    testWidgets('removes position from list', (tester) async {
      _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final ctrl = Get.find<PositionController>();
      final target = ctrl.positions.first;

      ctrl.deletePosition(target.id);
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(ctrl.positions.any((p) => p.id == target.id), isFalse);
    });

    testWidgets('also removes employees in that position', (tester) async {
      _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final posCtrl = Get.find<PositionController>();
      final empCtrl = Get.find<EmployeeController>();

      final pos = posCtrl.positions.firstWhere(
        (p) => empCtrl.employees.any((e) => e.positionId == p.id),
      );
      posCtrl.deletePosition(pos.id);
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(empCtrl.employees.any((e) => e.positionId == pos.id), isFalse);
    });

    testWidgets('does nothing for unknown id', (tester) async {
      _setupControllers();
      await tester.pumpWidget(_appWith(const SizedBox()));
      final ctrl = Get.find<PositionController>();
      final before = ctrl.positions.length;

      // deletePosition returns early for unknown id — no snackbar triggered
      ctrl.deletePosition('no_such_id');
      await tester.pump(Duration.zero);

      expect(ctrl.positions.length, before);
    });
  });
}