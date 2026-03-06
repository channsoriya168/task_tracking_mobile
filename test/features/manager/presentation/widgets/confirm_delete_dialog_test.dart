import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';

Widget _testApp(Widget child) => MaterialApp(home: child);

void main() {
  group('showConfirmDeleteDialog', () {
    testWidgets('renders title and content text', (tester) async {
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showConfirmDeleteDialog(
                ctx,
                title: 'Delete Employee',
                content: 'Remove "Alice" from the team?',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Employee'), findsOneWidget);
      expect(find.text('Remove "Alice" from the team?'), findsOneWidget);
    });

    testWidgets('has Cancel and Delete buttons', (tester) async {
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => showConfirmDeleteDialog(
                ctx,
                title: 'Delete Position',
                content: 'Delete position "Engineering"?',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Cancel button closes dialog and returns false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await showConfirmDeleteDialog(
                  ctx,
                  title: 'Delete',
                  content: 'Are you sure?',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Delete button closes dialog and returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await showConfirmDeleteDialog(
                  ctx,
                  title: 'Delete',
                  content: 'Are you sure?',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(result, true);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}