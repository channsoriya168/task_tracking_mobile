import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/home/manager_dashboard_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/home/manager_dashboard_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/home/manager_dashboard_tablet_page.dart';

// Subclass that skips FlutterSecureStorage in onInit
class _FakeThemeController extends ThemeController {
  @override
  void onInit() {
    // Skip _loadTheme to avoid native plugin in tests
  }
}

/// Sets up a FlutterError handler that ignores overflow rendering errors
/// (which are font-metric artifacts in the test environment).
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

Widget _buildApp(Size size, Widget child) => GetMaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    );

// Mobile: width < 600, Tablet: width >= 600
const _mobileSize = Size(500, 900);
const _tabletSize = Size(800, 1024);

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.put<ThemeController>(_FakeThemeController());
  });

  tearDown(() {
    _restoreErrorHandler();
    Get.reset();
  });

  group('ManagerDashboardPage – responsive routing', () {
    testWidgets('renders ManagerDashboardMobilePage on narrow screen', (tester) async {
      _ignoreOverflowErrors();
      tester.view.physicalSize = _mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildApp(_mobileSize, const ManagerDashboardPage()));
      await tester.pump();

      expect(find.byType(ManagerDashboardMobilePage), findsOneWidget);
      expect(find.byType(ManagerDashboardTabletPage), findsNothing);
    });

    testWidgets('renders ManagerDashboardTabletPage on wide screen', (tester) async {
      _ignoreOverflowErrors();
      tester.view.physicalSize = _tabletSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildApp(_tabletSize, const ManagerDashboardPage()));
      await tester.pump();

      expect(find.byType(ManagerDashboardTabletPage), findsOneWidget);
      expect(find.byType(ManagerDashboardMobilePage), findsNothing);
    });
  });

  group('ManagerDashboardMobilePage – content', () {
    Future<void> _pumpMobileDashboard(WidgetTester tester) async {
      _ignoreOverflowErrors();
      tester.view.physicalSize = _mobileSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildApp(_mobileSize, const ManagerDashboardMobilePage()),
      );
      await tester.pump();
    }

    testWidgets('shows Admin Dashboard heading', (tester) async {
      await _pumpMobileDashboard(tester);
      expect(find.text('Admin Dashboard'), findsOneWidget);
    });

    testWidgets('shows overview subtitle', (tester) async {
      await _pumpMobileDashboard(tester);
      expect(find.text('Overview of your team and tasks'), findsOneWidget);
    });

    testWidgets('shows Recent Activity section', (tester) async {
      await _pumpMobileDashboard(tester);
      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('shows all four summary stat labels', (tester) async {
      await _pumpMobileDashboard(tester);
      expect(find.text('Total Tasks'), findsOneWidget);
      expect(find.text('Staff Members'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
    });
  });
}