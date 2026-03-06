// ─────────────────────────────────────────────────────────────────────────────
// TUTORIAL: Unit Testing a Model in Flutter
//
// KEY CONCEPTS:
//  • import 'package:flutter_test/flutter_test.dart' — gives you test(), group(),
//    expect(), and all matchers (isTrue, isFalse, equals, isNull, isNotNull…)
//  • group()  — organises related tests under a label (like a folder)
//  • test()   — a single test case with a description + a callback
//  • expect(actual, matcher) — asserts that actual satisfies the matcher
//
// NO Flutter widgets, NO GetX needed for a pure model test.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

// ── Helper: builds a basic TaskModel so every test starts clean ──────────────
//
// TUTORIAL: Use a factory helper instead of repeating constructor arguments
// in every test. Keeps tests short and easy to read.
TaskModel _makeTask({
  String id = '1',
  String title = 'Test Task',
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  String? acceptedBy,
  String? assignedToId,
  List<String> members = const [],
  List<String> progressItems = const [],
}) {
  return TaskModel(
    id: id,
    title: title,
    status: status,
    priority: priority,
    dueDate: dueDate,
    acceptedBy: acceptedBy,
    assignedToId: assignedToId,
    members: members,
    progressItems: progressItems,
  );
}

void main() {
  // ── Group 1: Constructor & Default Values ────────────────────────────────
  //
  // TUTORIAL: Always test that your object is created correctly with the
  // right default values. This catches accidental changes later.
  group('TaskModel – constructor & defaults', () {
    test('stores id and title correctly', () {
      final task = _makeTask(id: 'abc', title: 'My Task');

      // expect(actual, matcher)
      // equals() checks exact value equality
      expect(task.id, equals('abc'));
      expect(task.title, equals('My Task'));
    });

    test('default status is todo', () {
      final task = _makeTask();
      expect(task.status, equals(TaskStatus.todo));
    });

    test('default priority is medium', () {
      final task = _makeTask();
      expect(task.priority, equals(TaskPriority.medium));
    });

    test('default category is General', () {
      final task = _makeTask();
      expect(task.category, equals('General'));
    });

    test('default description is empty string', () {
      final task = _makeTask();
      expect(task.description, equals(''));
    });

    test('dueDate is null by default', () {
      final task = _makeTask();
      // isNull is a matcher that checks the value is null
      expect(task.dueDate, isNull);
    });

    test('createdAt is set automatically when not provided', () {
      final before = DateTime.now();
      final task = _makeTask();
      final after = DateTime.now();

      // isNotNull: value must not be null
      expect(task.createdAt, isNotNull);
      // Make sure createdAt is between before and after
      expect(
        task.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(task.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('custom createdAt is preserved', () {
      final fixedDate = DateTime(2025, 1, 15);
      final task = TaskModel(id: '1', title: 'T', createdAt: fixedDate);
      expect(task.createdAt, equals(fixedDate));
    });
  });

  // ── Group 2: statusLabel ─────────────────────────────────────────────────
  //
  // TUTORIAL: Test every branch of a switch/if statement separately.
  // Each enum value is its own test case — never lump them together.
  group('TaskModel – statusLabel', () {
    test('todo → "Pending"', () {
      final task = _makeTask(status: TaskStatus.todo);
      expect(task.statusLabel, equals('Pending'));
    });

    test('inProgress → "In Progress"', () {
      final task = _makeTask(status: TaskStatus.inProgress);
      expect(task.statusLabel, equals('In Progress'));
    });

    test('done → "Complete"', () {
      final task = _makeTask(status: TaskStatus.done);
      expect(task.statusLabel, equals('Complete'));
    });

    test('fail → "Fail"', () {
      final task = _makeTask(status: TaskStatus.fail);
      expect(task.statusLabel, equals('Fail'));
    });
  });

  // ── Group 3: priorityLabel ───────────────────────────────────────────────
  group('TaskModel – priorityLabel', () {
    test('high → "High"', () {
      expect(_makeTask(priority: TaskPriority.high).priorityLabel, equals('High'));
    });

    test('medium → "Medium"', () {
      expect(_makeTask(priority: TaskPriority.medium).priorityLabel, equals('Medium'));
    });

    test('low → "Low"', () {
      expect(_makeTask(priority: TaskPriority.low).priorityLabel, equals('Low'));
    });
  });

  // ── Group 4: isOverdue ───────────────────────────────────────────────────
  //
  // TUTORIAL: For boolean getters, cover every logical branch:
  //   • no dueDate       → not overdue
  //   • dueDate in past  → overdue (unless done)
  //   • dueDate in future→ not overdue
  //   • status == done   → never overdue even if past due
  group('TaskModel – isOverdue', () {
    test('false when dueDate is null', () {
      final task = _makeTask(dueDate: null);
      // isFalse is a matcher for false boolean values
      expect(task.isOverdue, isFalse);
    });

    test('false when dueDate is in the future', () {
      final task = _makeTask(
        dueDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(task.isOverdue, isFalse);
    });

    test('true when dueDate is in the past and status is todo', () {
      final task = _makeTask(
        status: TaskStatus.todo,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      // isTrue is a matcher for true boolean values
      expect(task.isOverdue, isTrue);
    });

    test('true when dueDate is in the past and status is inProgress', () {
      final task = _makeTask(
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(task.isOverdue, isTrue);
    });

    test('false when status is done, even if dueDate is in the past', () {
      // TUTORIAL: This is an important edge case — done tasks are never overdue.
      final task = _makeTask(
        status: TaskStatus.done,
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(task.isOverdue, isFalse);
    });

    test('false when status is fail and dueDate is in the past', () {
      // fail tasks still show as overdue — only done is exempt
      final task = _makeTask(
        status: TaskStatus.fail,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(task.isOverdue, isTrue);
    });
  });

  // ── Group 5: copyWith ────────────────────────────────────────────────────
  //
  // TUTORIAL: copyWith must:
  //   (a) change only the fields you pass in
  //   (b) preserve everything else
  //   (c) not mutate the original object
  //   (d) honour special flags like clearDueDate / clearAcceptedBy
  group('TaskModel – copyWith', () {
    test('changes title and preserves other fields', () {
      final original = _makeTask(id: '42', title: 'Old Title', priority: TaskPriority.high);
      final copy = original.copyWith(title: 'New Title');

      expect(copy.title, equals('New Title'));
      // id is final and must be preserved
      expect(copy.id, equals('42'));
      // priority must be unchanged
      expect(copy.priority, equals(TaskPriority.high));
    });

    test('original is not mutated after copyWith', () {
      final original = _makeTask(title: 'Original');
      original.copyWith(title: 'Changed');
      // The original title should still be 'Original'
      expect(original.title, equals('Original'));
    });

    test('changes status only', () {
      final original = _makeTask(status: TaskStatus.todo);
      final copy = original.copyWith(status: TaskStatus.done);

      expect(copy.status, equals(TaskStatus.done));
      expect(original.status, equals(TaskStatus.todo)); // original unchanged
    });

    test('clearDueDate flag sets dueDate to null', () {
      final original = _makeTask(
        dueDate: DateTime(2025, 6, 1),
      );
      final copy = original.copyWith(clearDueDate: true);

      // TUTORIAL: The special clearDueDate flag lets you set dueDate to null
      // even though Dart can't distinguish "null passed" from "not passed".
      expect(copy.dueDate, isNull);
    });

    test('clearAcceptedBy flag sets acceptedBy to null', () {
      final original = _makeTask(acceptedBy: 'Alice');
      final copy = original.copyWith(clearAcceptedBy: true);

      expect(copy.acceptedBy, isNull);
    });

    test('clearAssignedToId flag sets assignedToId to null', () {
      final original = _makeTask(assignedToId: 'staff1');
      final copy = original.copyWith(clearAssignedToId: true);

      expect(copy.assignedToId, isNull);
    });

    test('members list is copied, not shared', () {
      // TUTORIAL: Defensive copy check — modifying the copy's list must not
      // affect the original. This guards against shallow-copy bugs.
      final original = _makeTask(members: ['Alice', 'Bob']);
      final copy = original.copyWith(members: ['Alice', 'Bob', 'Charlie']);

      expect(original.members.length, equals(2));
      expect(copy.members.length, equals(3));
    });

    test('preserves createdAt from original', () {
      final fixedDate = DateTime(2024, 3, 10);
      final original = TaskModel(id: '1', title: 'T', createdAt: fixedDate);
      final copy = original.copyWith(title: 'Updated');

      expect(copy.createdAt, equals(fixedDate));
    });
  });
}
