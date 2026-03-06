// ─────────────────────────────────────────────────────────────────────────────
// TUTORIAL: Widget Testing in Flutter
//
// NEW CONCEPTS vs unit/controller tests:
//  • testWidgets()     — like test() but gives you a WidgetTester
//  • tester.pumpWidget() — renders the widget tree into a fake screen
//  • tester.pumpAndSettle() — renders + waits for all animations to finish
//  • find.*            — locates widgets in the tree (finders)
//  • expect(find.*, findsOneWidget) — asserts how many widgets were found
//  • tester.tap()      — simulates a tap gesture
//  • tester.drag()     — simulates a swipe/drag gesture
//  • GetMaterialApp    — required wrapper so GetX + Material widgets work
//
// WIDGET TEST FINDERS (most common):
//  find.text('Hello')       — find a Text widget with that string
//  find.byType(ElevatedButton) — find by widget type
//  find.byIcon(Icons.delete)   — find by icon
//  find.byKey(Key('my-key'))   — find by key
//
// WIDGET TEST MATCHERS (most common):
//  findsOneWidget    — exactly one match
//  findsNothing      — zero matches
//  findsWidgets      — one or more matches
//  findsNWidgets(n)  — exactly n matches
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_card.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_empty_state.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/task_filter_tab.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

TaskModel _task({
  String id = '1',
  String title = 'Test Task',
  String category = 'Engineering',
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  String? acceptedBy,
  List<String> progressItems = const [],
}) {
  return TaskModel(
    id: id,
    title: title,
    category: category,
    status: status,
    priority: priority,
    dueDate: dueDate,
    acceptedBy: acceptedBy,
    progressItems: progressItems,
  );
}

// TUTORIAL: pumpWidget() needs a full Material widget tree to work.
// Wrap your widget in GetMaterialApp > Scaffold so theme, navigation,
// and GetX all work correctly — exactly like the real app does.
Widget _wrap(Widget child) {
  return GetMaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.put<TaskController>(TaskController());
  });

  tearDown(() => Get.reset());

  // ══════════════════════════════════════════════════════════════════════════
  // Part 1: TaskCard
  // ══════════════════════════════════════════════════════════════════════════

  group('TaskCard – renders content', () {
    // TUTORIAL: Every widget test:
    //  1. pump the widget  →  await tester.pumpWidget(...)
    //  2. settle animations → await tester.pumpAndSettle()
    //  3. find & assert    →  expect(find.*, matcher)

    testWidgets('shows task title', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(title: 'Fix the login bug'),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      // find.text() searches the entire widget tree for a Text with this value
      expect(find.text('Fix the login bug'), findsOneWidget);
    });

    testWidgets('shows category in uppercase', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(category: 'Design'),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.text('DESIGN'), findsOneWidget);
    });

    testWidgets('shows priority label', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(priority: TaskPriority.high),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('shows acceptedBy avatar initials when set', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(acceptedBy: 'Alice Bob'),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      // Avatar shows first letters: "AB"
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('does not show avatar when acceptedBy is null', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(acceptedBy: null),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      // No initials text should exist
      // find.text with a single letter won't match unless it's actually there
      // We verify no 2-letter initial container is shown by checking the
      // task has no acceptedBy, so there's no avatar text at all
      expect(find.text('AB'), findsNothing);
    });
  });

  // ── Action buttons ─────────────────────────────────────────────────────────
  //
  // TUTORIAL: Different task statuses show different action buttons.
  // Test each status independently.
  group('TaskCard – action buttons by status', () {
    testWidgets('shows "Accept" button for todo tasks', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.todo),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
        onAccept: () {}, // onAccept must be non-null for todo
      )));
      await tester.pumpAndSettle();

      expect(find.text('Accept'), findsOneWidget);
    });

    testWidgets('shows "Progress" button for inProgress tasks', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.inProgress),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
        onFinish: () {}, // onFinish must be non-null for inProgress
      )));
      await tester.pumpAndSettle();

      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('shows "Detail" button for done tasks', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.done),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);
    });
  });

  // ── Overdue label ──────────────────────────────────────────────────────────
  group('TaskCard – overdue indicator', () {
    testWidgets('shows overdue text when task is past due', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(
          status: TaskStatus.todo,
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      // The footer label starts with "Overdue ·" when isOverdue is true
      // find.textContaining() searches for a substring inside any Text widget
      expect(find.textContaining('Overdue'), findsOneWidget);
    });

    testWidgets('does not show overdue for done tasks', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(
          status: TaskStatus.done,
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('Overdue'), findsNothing);
    });
  });

  // ── Progress strip ─────────────────────────────────────────────────────────
  group('TaskCard – progress strip', () {
    testWidgets('shows LinearProgressIndicator for inProgress tasks',
        (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.inProgress),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      // find.byType() finds widgets by their class type
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('does NOT show progress strip for todo tasks', (tester) async {
      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.todo),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  // ── Tap & drag interactions ────────────────────────────────────────────────
  //
  // TUTORIAL: tester.tap(finder) simulates a finger tap on a widget.
  // Use a boolean flag variable to verify the callback was triggered.
  group('TaskCard – interactions', () {
    testWidgets('tapping Accept button fires onAccept', (tester) async {
      bool accepted = false;

      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.todo),
        onToggle: () {},
        onDelete: () {},
        onTap: () {},
        onAccept: () => accepted = true,
      )));
      await tester.pumpAndSettle();

      // tap the "Accept" text button
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(accepted, isTrue);
    });

    testWidgets('swipe left fires onDelete', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.todo),
        onToggle: () {},
        onDelete: () => deleted = true,
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      // TUTORIAL: tester.drag(finder, offset) simulates a swipe.
      // Offset(-500, 0) = swipe far to the left → triggers Dismissible
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('done tasks cannot be swiped to delete', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(_wrap(TaskCard(
        task: _task(status: TaskStatus.done),
        onToggle: () {},
        onDelete: () => deleted = true,
        onTap: () {},
      )));
      await tester.pumpAndSettle();

      // Done tasks have DismissDirection.none — swipe should do nothing
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(deleted, isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Part 2: TaskEmptyState
  // ══════════════════════════════════════════════════════════════════════════
  //
  // TUTORIAL: Simple widgets with no callbacks are the easiest to test —
  // just verify the expected text and icons are present.

  group('TaskEmptyState – renders', () {
    testWidgets('shows "No tasks found" text', (tester) async {
      await tester.pumpWidget(_wrap(const TaskEmptyState(isDark: false)));
      await tester.pumpAndSettle();

      expect(find.text('No tasks found'), findsOneWidget);
    });

    testWidgets('shows inbox icon', (tester) async {
      await tester.pumpWidget(_wrap(const TaskEmptyState(isDark: false)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(_wrap(const TaskEmptyState(isDark: true)));
      await tester.pumpAndSettle();

      // In dark mode the widget should still render the same text
      expect(find.text('No tasks found'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Part 3: TaskFilterTab
  // ══════════════════════════════════════════════════════════════════════════

  group('TaskFilterTab – renders', () {
    late TaskController ctrl;

    setUp(() {
      ctrl = Get.find<TaskController>();
    });

    testWidgets('shows filter label and count', (tester) async {
      await tester.pumpWidget(_wrap(TaskFilterTab(
        filter: 'Todo',
        count: 5,
        ctrl: ctrl,
        isDark: false,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Todo'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('"InProgress" filter displays as "In Progress"', (tester) async {
      // TUTORIAL: The widget maps the filter key "InProgress" to the display
      // label "In Progress". Test the label the user actually sees.
      await tester.pumpWidget(_wrap(TaskFilterTab(
        filter: 'InProgress',
        count: 3,
        ctrl: ctrl,
        isDark: false,
      )));
      await tester.pumpAndSettle();

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('tapping tab updates controller filterStatus', (tester) async {
      ctrl.filterStatus.value = 'Todo'; // start on Todo

      await tester.pumpWidget(_wrap(TaskFilterTab(
        filter: 'Complete',
        count: 2,
        ctrl: ctrl,
        isDark: false,
      )));
      await tester.pumpAndSettle();

      // Tap the "Complete" tab
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      // Controller filterStatus should now be "Complete"
      expect(ctrl.filterStatus.value, equals('Complete'));
    });
  });
}
