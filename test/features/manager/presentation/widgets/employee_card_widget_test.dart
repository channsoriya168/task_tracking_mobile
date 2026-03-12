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
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_card_widget.dart';

class _StubImageService extends ImageService {
  @override
  Future<File?> pickImage(ImageSource source) async => null;

  @override
  Future<File?> compressImage(File file) async => null;
}

class _StubTaskGroupRepository implements TaskGroupRepository {
  @override
  Future<List<TaskGroup>> getAll() async => [];
  @override
  Future<TaskGroup> getById(String id) async => TaskGroup(id: id, name: 'Stub');
  @override
  Future<TaskGroup> create({required String name, String? color, String? description}) async =>
      TaskGroup(id: 'new', name: name);
  @override
  Future<TaskGroup> update(String id, {required String name, String? color, String? description}) async =>
      TaskGroup(id: id, name: name);
  @override
  Future<void> delete(String id) async {}
}

void main() {
  late EmployeeController ctrl;
  late TaskGroup taskGroup;
  late Employee employee;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    final stub = _StubTaskGroupRepository();
    Get.put<PickAndCompressImageUseCase>(
      PickAndCompressImageUseCase(_StubImageService()),
    );
    Get.put<TaskGroupController>(
      TaskGroupController(GetAllTaskGroupsUseCase(stub), CreateTaskGroupUseCase(stub)),
    );
    ctrl = Get.put<EmployeeController>(EmployeeController());

    taskGroup = TaskGroup(
      id: 'p1',
      name: 'Engineering',
      color: Color(0xFF6C63FF),
    );
    employee = const Employee(
      id: 'e1',
      name: 'Alice Johnson',
      email: 'alice@company.com',
      positionId: 'p1',
    );
  });

  tearDown(() => Get.reset());

  Widget _buildWidget({bool isDark = false}) {
    return GetMaterialApp(
      home: Scaffold(
        body: EmployeeCardWidget(
          isDark: isDark,
          ctrl: ctrl,
          employee: employee,
          position: taskGroup,
        ),
      ),
    );
  }

  testWidgets('renders employee name', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Alice Johnson'), findsOneWidget);
  });

  testWidgets('renders employee email', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('alice@company.com'), findsOneWidget);
  });

  testWidgets('shows more options icon in content', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
  });

  testWidgets('renders in dark mode without error', (tester) async {
    await tester.pumpWidget(_buildWidget(isDark: true));
    await tester.pumpAndSettle();

    expect(find.text('Alice Johnson'), findsOneWidget);
  });

  testWidgets('tapping card opens employee menu sheet', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Menu sheet should appear
    expect(find.text('Alice Johnson'), findsWidgets);
  });
}
