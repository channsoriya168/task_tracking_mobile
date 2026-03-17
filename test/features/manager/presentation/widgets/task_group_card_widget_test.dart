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
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_group/task_group_card_widget.dart';

// ── Stubs ──────────────────────────────────────────────────────

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
  Future<TaskGroup> create({
    required String name,
    String? color,
    String? description,
  }) async => TaskGroup(id: 'new', name: name);

  @override
  Future<TaskGroup> update(
    String id, {
    required String name,
    String? color,
    String? description,
  }) async => TaskGroup(id: id, name: name);

  @override
  Future<void> delete(String id) async {}
}

// ── Test ───────────────────────────────────────────────────────

void main() {
  late TaskGroupController posCtrl;
  final taskGroup = TaskGroup(
    id: 'p1',
    name: 'Engineering',
    color: const Color(0xFF6C63FF),
  );

  setUp(() {
    Get.reset();
    Get.testMode = true;
    final stub = _StubTaskGroupRepository();
    Get.put<PickAndCompressImageUseCase>(
      PickAndCompressImageUseCase(_StubImageService()),
    );
    posCtrl = Get.put<TaskGroupController>(
      TaskGroupController(
        GetAllTaskGroupsUseCase(stub),
        CreateTaskGroupUseCase(stub),
      ),
    );
    Get.put<EmployeeController>(EmployeeController());
  });

  tearDown(() => Get.reset());

  Widget _buildWidget({int employeeCount = 3, bool isDark = false}) {
    return GetMaterialApp(
      home: Scaffold(
        body: TaskGroupCardWidget(
          isDark: isDark,
          ctrl: posCtrl,
          position: taskGroup,
          employeeCount: employeeCount,
        ),
      ),
    );
  }

  testWidgets('renders task group name', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Engineering'), findsOneWidget);
  });

  testWidgets('shows plural "members" when count > 1', (tester) async {
    await tester.pumpWidget(_buildWidget(employeeCount: 3));
    await tester.pumpAndSettle();

    expect(find.text('3 members'), findsOneWidget);
  });

  testWidgets('shows singular "member" when count is 1', (tester) async {
    await tester.pumpWidget(_buildWidget(employeeCount: 1));
    await tester.pumpAndSettle();

    expect(find.text('1 member'), findsOneWidget);
  });

  testWidgets('shows edit and delete action buttons', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_rounded), findsAtLeastNWidgets(1));
  });

  testWidgets('renders in dark mode without error', (tester) async {
    await tester.pumpWidget(_buildWidget(isDark: true));
    await tester.pumpAndSettle();

    expect(find.text('Engineering'), findsOneWidget);
  });

  testWidgets('swipe to delete shows confirmation dialog', (tester) async {
    await tester.pumpWidget(_buildWidget(employeeCount: 2));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete Position'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('delete dialog warns about employees when count > 0', (
    tester,
  ) async {
    await tester.pumpWidget(_buildWidget(employeeCount: 2));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 employees'), findsOneWidget);
  });

  testWidgets('delete dialog is simple when no employees', (tester) async {
    await tester.pumpWidget(_buildWidget(employeeCount: 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('Delete position'), findsOneWidget);
  });
}
