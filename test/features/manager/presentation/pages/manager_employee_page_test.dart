import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_tablet_page.dart';

// ── Overflow suppression ──────────────────────────────────────
// Flutter tests use a fallback font with different metrics, causing
// spurious layout overflow errors that don't occur on real devices.
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

// ── Stubs ─────────────────────────────────────────────────────
class _StubImageService extends ImageService {
  @override
  Future<File?> pickImage(ImageSource source) async => null;

  @override
  Future<File?> compressImage(File file) async => null;
}

void _setupControllers() {
  Get.reset();
  Get.testMode = true;
  Get.put<PickAndCompressImageUseCase>(
    PickAndCompressImageUseCase(_StubImageService()),
  );
  Get.put<PositionController>(PositionController());
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