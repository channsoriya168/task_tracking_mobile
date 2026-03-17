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
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_tablet_page.dart';

// ── Stubs ──────────────────────────────────────────────────────

class _StubImageService extends ImageService {
  @override
  Future<File?> pickImage(ImageSource source) async => null;

  @override
  Future<File?> compressImage(File file) async => null;
}

class _StubTaskGroupRepository implements TaskGroupRepository {
  @override
  Future<List<TaskGroup>> getAll() async => [
        TaskGroup(id: 'p1', name: 'Engineering'),
        TaskGroup(id: 'p2', name: 'Design'),
        TaskGroup(id: 'p3', name: 'Marketing'),
        TaskGroup(id: 'p4', name: 'Finance'),
      ];

  @override
  Future<TaskGroup> getById(String id) async =>
      TaskGroup(id: id, name: 'Stub');

  @override
  Future<TaskGroup> create({
    required String name,
    String? color,
    String? description,
  }) async =>
      TaskGroup(id: 'new', name: name);

  @override
  Future<TaskGroup> update(
    String id, {
    required String name,
    String? color,
    String? description,
  }) async =>
      TaskGroup(id: id, name: name);

  @override
  Future<void> delete(String id) async {}
}

// ── Overflow suppression ───────────────────────────────────────

void Function(FlutterErrorDetails)? _originalOnError;

void _ignoreOverflowErrors() {
  _originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final msg = details.exceptionAsString();
    if (msg.contains('overflowed by') || msg.contains('RenderFlex')) return;
    _originalOnError?.call(details);
  };
}

void _restoreErrorHandler() {
  FlutterError.onError = _originalOnError;
  _originalOnError = null;
}

// ── Setup ──────────────────────────────────────────────────────

void _setupControllers() {
  Get.reset();
  Get.testMode = true;
  final stub = _StubTaskGroupRepository();
  Get.put<PickAndCompressImageUseCase>(
    PickAndCompressImageUseCase(_StubImageService()),
  );
  Get.put<TaskGroupController>(
    TaskGroupController(
      GetAllTaskGroupsUseCase(stub),
      CreateTaskGroupUseCase(stub),
    ),
  );
  Get.put<EmployeeController>(EmployeeController());
}

Widget _buildApp(Size size, Widget child) => GetMaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );

const _mobileSize = Size(500, 900);
const _tabletSize = Size(800, 1024);

void main() {
  tearDown(() {
    _restoreErrorHandler();
    Get.reset();
  });

  group('ManagerEmployeePage – responsive routing', () {
    testWidgets('renders mobile page on narrow screen', (tester) async {
      _ignoreOverflowErrors();
      _setupControllers();
      tester.view.physicalSize = _mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildApp(_mobileSize, const ManagerEmployeePage()));
      await tester.pump();

      expect(find.byType(ManagerEmployeeMobilePage), findsOneWidget);
      expect(find.byType(ManagerEmployeeTabletPage), findsNothing);
    });

    testWidgets('renders tablet page on wide screen', (tester) async {
      _ignoreOverflowErrors();
      _setupControllers();
      tester.view.physicalSize = _tabletSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildApp(_tabletSize, const ManagerEmployeePage()));
      await tester.pump();

      expect(find.byType(ManagerEmployeeTabletPage), findsOneWidget);
      expect(find.byType(ManagerEmployeeMobilePage), findsNothing);
    });
  });

  group('ManagerEmployeeMobilePage – content', () {
    Future<void> _pumpMobilePage(WidgetTester tester) async {
      _ignoreOverflowErrors();
      _setupControllers();
      // Ensure task groups are loaded before rendering (fetch is async).
      await Get.find<TaskGroupController>().fetchTaskGroups();
      tester.view.physicalSize = _mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildApp(_mobileSize, const ManagerEmployeeMobilePage()));
      await tester.pumpAndSettle();
    }

    testWidgets('shows search bar', (tester) async {
      await _pumpMobilePage(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows employee names from mock data', (tester) async {
      await _pumpMobilePage(tester);
      expect(find.text('Alice Johnson'), findsOneWidget);
    });

    testWidgets('shows fab add button', (tester) async {
      await _pumpMobilePage(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
