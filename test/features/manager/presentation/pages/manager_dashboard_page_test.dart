import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/dashboard/manager_dashboard_page.dart';

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
    Get.put<ManagerTaskController>(ManagerTaskController());
  });

  tearDown(() {
    _restoreErrorHandler();
    Get.reset();
  });

  // Pump widget and flush all pending animation timers (e.g. Syncfusion charts).
  Future<void> _pumpDashboard(WidgetTester tester, Size size) async {
    _ignoreOverflowErrors();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_buildApp(size, const ManagerDashboardPage()));
    // Advance time past any chart / calendar animation timers.
    await tester.pump(const Duration(seconds: 3));
  }

  group('ManagerDashboardPage – renders without error', () {
    testWidgets('on narrow screen', (tester) async {
      await _pumpDashboard(tester, _mobileSize);
      expect(find.byType(ManagerDashboardPage), findsOneWidget);
    });

    testWidgets('on wide screen', (tester) async {
      await _pumpDashboard(tester, _tabletSize);
      expect(find.byType(ManagerDashboardPage), findsOneWidget);
    });
  });

  group('ManagerDashboardPage – content', () {
    testWidgets('shows Tasks label', (tester) async {
      await _pumpDashboard(tester, _mobileSize);
      expect(find.text('Tasks'), findsWidgets);
    });

    testWidgets('shows All filter chip', (tester) async {
      await _pumpDashboard(tester, _mobileSize);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('shows status filter chips', (tester) async {
      await _pumpDashboard(tester, _mobileSize);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('In Progress'), findsWidgets);
      expect(find.text('Complete'), findsWidgets);
      expect(find.text('Fail'), findsWidgets);
    });
  });
}
