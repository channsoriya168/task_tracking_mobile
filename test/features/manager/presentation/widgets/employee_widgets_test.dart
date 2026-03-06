import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

void main() {
  // ── employeeInitials helper ────────────────────────────────────
  group('employeeInitials', () {
    test('returns initials for two-word name', () {
      expect(employeeInitials('Alice Johnson'), 'AJ');
    });

    test('returns single initial for one-word name', () {
      expect(employeeInitials('Bob'), 'B');
    });

    test('returns initials uppercased', () {
      expect(employeeInitials('charlie brown'), 'CB');
    });

    test('returns ? for empty string', () {
      expect(employeeInitials(''), '?');
    });

    test('uses first two parts for names with more than two words', () {
      expect(employeeInitials('John Middle Doe'), 'JM');
    });
  });

  // ── EmployeeAvatar widget ──────────────────────────────────────
  group('EmployeeAvatar', () {
    testWidgets('shows initials when no imagePath provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmployeeAvatar(
              name: 'Diana Prince',
              color: Colors.blue,
              radius: 22,
            ),
          ),
        ),
      );

      expect(find.text('DP'), findsOneWidget);
    });

    testWidgets('shows single initial for one-word name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmployeeAvatar(
              name: 'Grace',
              color: Colors.green,
              radius: 20,
            ),
          ),
        ),
      );

      expect(find.text('G'), findsOneWidget);
    });

    testWidgets('renders CircleAvatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmployeeAvatar(
              name: 'Test User',
              color: Colors.purple,
              radius: 24,
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}