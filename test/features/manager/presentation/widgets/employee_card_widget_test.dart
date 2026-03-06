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
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_card_widget.dart';

class _StubImageService extends ImageService {
  @override
  Future<File?> pickImage(ImageSource source) async => null;

  @override
  Future<File?> compressImage(File file) async => null;
}

void main() {
  late EmployeeController ctrl;
  late Position position;
  late Employee employee;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.put<PickAndCompressImageUseCase>(
      PickAndCompressImageUseCase(_StubImageService()),
    );
    Get.put<PositionController>(PositionController());
    ctrl = Get.put<EmployeeController>(EmployeeController());

    position = const Position(id: 'p1', name: 'Engineering', color: Color(0xFF6C63FF));
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
          position: position,
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

  testWidgets('shows Dismissible widget', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(Dismissible), findsOneWidget);
  });

  testWidgets('shows edit icon in content', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
  });

  testWidgets('renders in dark mode without error', (tester) async {
    await tester.pumpWidget(_buildWidget(isDark: true));
    await tester.pumpAndSettle();

    expect(find.text('Alice Johnson'), findsOneWidget);
  });

  testWidgets('swipe to delete shows confirmation dialog', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete Employee'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}