// ─────────────────────────────────────────────────────────────────────────────
// TUTORIAL: Unit Testing a GetX Controller
//
// NEW CONCEPTS vs model test:
//  • Get.put()      — registers a controller into GetX's dependency container
//  • Get.reset()    — clears all registered dependencies (ALWAYS call in tearDown)
//  • Get.testMode   — disables navigation/snackbar side-effects during tests
//  • setUp()        — runs BEFORE every test (opposite of tearDown)
//  • tearDown()     — runs AFTER every test (use for cleanup)
//  • RxList / .obs  — GetX reactive list; treat it like a normal List in tests
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

// ── Helper: creates a fresh registered controller ────────────────────────────
//
// TUTORIAL: Always call Get.reset() before Get.put() so previous test state
// doesn't bleed into the next test.
TaskController _buildController() {
  Get.reset();
  Get.testMode = true;
  return Get.put<TaskController>(TaskController());
}

// ── Helper: builds a minimal TaskModel for test data ─────────────────────────
TaskModel _task({
  required String id,
  String title = 'Task',
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  String? acceptedBy,
  String? assignedToId,
}) {
  return TaskModel(
    id: id,
    title: title,
    status: status,
    priority: priority,
    dueDate: dueDate,
    acceptedBy: acceptedBy,
    assignedToId: assignedToId,
  );
}

void main() {
  // TUTORIAL: tearDown runs after EVERY test automatically.
  // Get.reset() wipes the GetX container so tests don't share state.
  tearDown(() => Get.reset());

  // ── Group 1: Initial State ─────────────────────────────────────────────────
  //
  // TUTORIAL: The first group always checks what the controller looks like
  // right after onInit() runs. This is your baseline.
  group('TaskController – initial state', () {
    test('tasks are populated with sample data on init', () {
      final ctrl = _buildController();
      // isNotEmpty: the list has at least one item
      expect(ctrl.tasks, isNotEmpty);
    });

    test('navIndex starts at 0', () {
      final ctrl = _buildController();
      expect(ctrl.navIndex.value, equals(0));
    });

    test('filterStatus starts as "Todo"', () {
      final ctrl = _buildController();
      expect(ctrl.filterStatus.value, equals('Todo'));
    });

    test('searchQuery starts empty', () {
      final ctrl = _buildController();
      expect(ctrl.searchQuery.value, equals(''));
    });
  });

  // ── Group 2: Computed counts ───────────────────────────────────────────────
  //
  // TUTORIAL: Computed getters (totalTasks, completedTasks…) should always
  // reflect the current state of the tasks list. Test them after you know the
  // sample data shape, or after you control the list yourself.
  group('TaskController – computed counts', () {
    test('totalTasks equals tasks.length', () {
      final ctrl = _buildController();
      expect(ctrl.totalTasks, equals(ctrl.tasks.length));
    });

    test('completedTasks counts only done tasks', () {
      final ctrl = _buildController();
      final expected = ctrl.tasks.where((t) => t.status == TaskStatus.done).length;
      expect(ctrl.completedTasks, equals(expected));
    });

    test('pendingCount counts only todo tasks', () {
      final ctrl = _buildController();
      final expected = ctrl.tasks.where((t) => t.status == TaskStatus.todo).length;
      expect(ctrl.pendingCount, equals(expected));
    });

    test('inProgressTasks counts only inProgress tasks', () {
      final ctrl = _buildController();
      final expected = ctrl.tasks.where((t) => t.status == TaskStatus.inProgress).length;
      expect(ctrl.inProgressTasks, equals(expected));
    });

    test('failCount counts only fail tasks', () {
      final ctrl = _buildController();
      final expected = ctrl.tasks.where((t) => t.status == TaskStatus.fail).length;
      expect(ctrl.failCount, equals(expected));
    });

    test('todoCount is an alias for pendingCount', () {
      final ctrl = _buildController();
      expect(ctrl.todoCount, equals(ctrl.pendingCount));
    });

    test('inReviewCount is an alias for inProgressTasks', () {
      final ctrl = _buildController();
      expect(ctrl.inReviewCount, equals(ctrl.inProgressTasks));
    });
  });

  // ── Group 3: completionRate ────────────────────────────────────────────────
  group('TaskController – completionRate', () {
    test('returns 0 when tasks list is empty', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      // closeTo(value, delta) — useful for floating point comparisons
      expect(ctrl.completionRate, closeTo(0.0, 0.001));
    });

    test('returns 1.0 when all tasks are done', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.addAll([
        _task(id: '1', status: TaskStatus.done),
        _task(id: '2', status: TaskStatus.done),
      ]);
      expect(ctrl.completionRate, closeTo(1.0, 0.001));
    });

    test('returns 0.5 when half the tasks are done', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.addAll([
        _task(id: '1', status: TaskStatus.done),
        _task(id: '2', status: TaskStatus.todo),
      ]);
      expect(ctrl.completionRate, closeTo(0.5, 0.001));
    });
  });

  // ── Group 4: CRUD ──────────────────────────────────────────────────────────
  //
  // TUTORIAL: For every mutating method test:
  //   (a) the happy path (it works)
  //   (b) the no-op / not-found case (nothing explodes)
  group('TaskController – CRUD', () {
    test('addTask appends to the list', () {
      final ctrl = _buildController();
      final before = ctrl.tasks.length;
      ctrl.addTask(_task(id: 'new1', title: 'Brand New Task'));

      expect(ctrl.tasks.length, equals(before + 1));
      expect(ctrl.tasks.any((t) => t.id == 'new1'), isTrue);
    });

    test('updateTask replaces the matching task', () {
      final ctrl = _buildController();
      final original = ctrl.tasks.first;
      final updated = original.copyWith(title: 'Updated Title');
      ctrl.updateTask(updated);

      final found = ctrl.tasks.firstWhere((t) => t.id == original.id);
      expect(found.title, equals('Updated Title'));
    });

    test('updateTask does nothing when id is not found', () {
      final ctrl = _buildController();
      final before = ctrl.tasks.length;
      ctrl.updateTask(_task(id: 'ghost_id', title: 'Ghost'));
      // list length must be unchanged
      expect(ctrl.tasks.length, equals(before));
    });

    test('deleteTask removes the task by id', () {
      final ctrl = _buildController();
      final target = ctrl.tasks.first;
      ctrl.deleteTask(target.id);

      expect(ctrl.tasks.any((t) => t.id == target.id), isFalse);
    });

    test('deleteTask does nothing for unknown id', () {
      final ctrl = _buildController();
      final before = ctrl.tasks.length;
      ctrl.deleteTask('no_such_id');
      expect(ctrl.tasks.length, equals(before));
    });
  });

  // ── Group 5: toggleComplete ────────────────────────────────────────────────
  group('TaskController – toggleComplete', () {
    test('todo → done when toggled', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: 't1', status: TaskStatus.todo));

      ctrl.toggleComplete('t1');

      expect(ctrl.tasks.first.status, equals(TaskStatus.done));
    });

    test('done → todo when toggled again', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: 't1', status: TaskStatus.done));

      ctrl.toggleComplete('t1');

      expect(ctrl.tasks.first.status, equals(TaskStatus.todo));
    });

    test('does nothing when id is not found', () {
      final ctrl = _buildController();
      final before = ctrl.tasks.length;
      ctrl.toggleComplete('ghost');
      expect(ctrl.tasks.length, equals(before));
    });
  });

  // ── Group 6: acceptTask ────────────────────────────────────────────────────
  group('TaskController – acceptTask', () {
    test('sets status to inProgress', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: 'a1', status: TaskStatus.todo));

      ctrl.acceptTask('a1');

      expect(ctrl.tasks.first.status, equals(TaskStatus.inProgress));
    });

    test('sets acceptedBy to "You" by default', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: 'a1'));

      ctrl.acceptTask('a1');

      expect(ctrl.tasks.first.acceptedBy, equals('You'));
    });

    test('uses provided acceptedBy value', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: 'a1'));

      ctrl.acceptTask('a1', acceptedBy: 'Alice');

      expect(ctrl.tasks.first.acceptedBy, equals('Alice'));
    });

    test('does nothing when id is not found', () {
      final ctrl = _buildController();
      final before = ctrl.tasks.length;
      ctrl.acceptTask('ghost');
      expect(ctrl.tasks.length, equals(before));
    });
  });

  // ── Group 7: finishTask ────────────────────────────────────────────────────
  group('TaskController – finishTask', () {
    test('sets status to done', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: 'f1', status: TaskStatus.inProgress));

      ctrl.finishTask('f1');

      expect(ctrl.tasks.first.status, equals(TaskStatus.done));
    });

    test('updates description when provided', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: 'f1'));

      ctrl.finishTask('f1', description: 'All done!');

      expect(ctrl.tasks.first.description, equals('All done!'));
    });

    test('does nothing when id is not found', () {
      final ctrl = _buildController();
      final before = ctrl.tasks.length;
      ctrl.finishTask('ghost');
      expect(ctrl.tasks.length, equals(before));
    });
  });

  // ── Group 8: filteredTasks – filter by status ──────────────────────────────
  //
  // TUTORIAL: For filtering logic, set up a controlled list so you know
  // exactly what results to expect. Never rely on sample data for filter tests.
  group('TaskController – filteredTasks (status filter)', () {
    // setUp runs BEFORE every test inside this group
    // Use it to prepare shared state that each test needs
    late TaskController ctrl;

    setUp(() {
      ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.addAll([
        _task(id: '1', title: 'Todo A',       status: TaskStatus.todo),
        _task(id: '2', title: 'Todo B',       status: TaskStatus.todo),
        _task(id: '3', title: 'InProgress A', status: TaskStatus.inProgress),
        _task(id: '4', title: 'Done A',       status: TaskStatus.done),
        _task(id: '5', title: 'Fail A',       status: TaskStatus.fail),
      ]);
    });

    test('filterStatus "Todo" returns only todo tasks', () {
      ctrl.filterStatus.value = 'Todo';
      final result = ctrl.filteredTasks;
      expect(result.every((t) => t.status == TaskStatus.todo), isTrue);
      expect(result.length, equals(2));
    });

    test('filterStatus "Pending" also returns todo tasks', () {
      ctrl.filterStatus.value = 'Pending';
      final result = ctrl.filteredTasks;
      expect(result.every((t) => t.status == TaskStatus.todo), isTrue);
    });

    test('filterStatus "In Progress" returns only inProgress tasks', () {
      ctrl.filterStatus.value = 'In Progress';
      final result = ctrl.filteredTasks;
      expect(result.every((t) => t.status == TaskStatus.inProgress), isTrue);
      expect(result.length, equals(1));
    });

    test('filterStatus "Complete" returns only done tasks', () {
      ctrl.filterStatus.value = 'Complete';
      final result = ctrl.filteredTasks;
      expect(result.every((t) => t.status == TaskStatus.done), isTrue);
      expect(result.length, equals(1));
    });

    test('filterStatus "Fail" returns only fail tasks', () {
      ctrl.filterStatus.value = 'Fail';
      final result = ctrl.filteredTasks;
      expect(result.every((t) => t.status == TaskStatus.fail), isTrue);
      expect(result.length, equals(1));
    });
  });

  // ── Group 9: filteredTasks – search ───────────────────────────────────────
  group('TaskController – filteredTasks (search)', () {
    late TaskController ctrl;

    setUp(() {
      ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.filterStatus.value = 'Todo'; // keep filter open for todos
      ctrl.tasks.addAll([
        TaskModel(id: '1', title: 'Fix login bug',   description: 'auth issue',  category: 'Engineering', status: TaskStatus.todo),
        TaskModel(id: '2', title: 'Write docs',      description: 'api v2 docs', category: 'Documentation', status: TaskStatus.todo),
        TaskModel(id: '3', title: 'Design homepage', description: 'wireframes',  category: 'Design', status: TaskStatus.todo),
      ]);
    });

    test('empty search returns all (filtered by status)', () {
      ctrl.searchQuery.value = '';
      expect(ctrl.filteredTasks.length, equals(3));
    });

    test('search by title (case-insensitive)', () {
      ctrl.searchQuery.value = 'login';
      final result = ctrl.filteredTasks;
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
    });

    test('search by description', () {
      ctrl.searchQuery.value = 'wireframes';
      final result = ctrl.filteredTasks;
      expect(result.length, equals(1));
      expect(result.first.id, equals('3'));
    });

    test('search by category', () {
      ctrl.searchQuery.value = 'documentation';
      final result = ctrl.filteredTasks;
      expect(result.length, equals(1));
      expect(result.first.id, equals('2'));
    });

    test('search returns empty when no match', () {
      ctrl.searchQuery.value = 'zzznomatch';
      expect(ctrl.filteredTasks, isEmpty);
    });
  });

  // ── Group 10: pendingTasks & upcomingTasks ─────────────────────────────────
  group('TaskController – pendingTasks & upcomingTasks', () {
    test('pendingTasks returns only todo tasks', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.addAll([
        _task(id: '1', status: TaskStatus.todo),
        _task(id: '2', status: TaskStatus.done),
        _task(id: '3', status: TaskStatus.inProgress),
      ]);

      final result = ctrl.pendingTasks;
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
    });

    test('upcomingTasks excludes done tasks', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.addAll([
        _task(id: '1', status: TaskStatus.todo, dueDate: DateTime.now().add(const Duration(hours: 12))),
        _task(id: '2', status: TaskStatus.done, dueDate: DateTime.now().add(const Duration(hours: 12))),
      ]);

      final result = ctrl.upcomingTasks;
      // Only non-done task should appear
      expect(result.any((t) => t.id == '2'), isFalse);
      expect(result.any((t) => t.id == '1'), isTrue);
    });

    test('upcomingTasks excludes tasks with no dueDate', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(_task(id: '1', status: TaskStatus.todo, dueDate: null));

      expect(ctrl.upcomingTasks, isEmpty);
    });

    test('upcomingTasks excludes tasks due more than 3 days away', () {
      final ctrl = _buildController();
      ctrl.tasks.clear();
      ctrl.tasks.add(
        _task(id: '1', status: TaskStatus.todo, dueDate: DateTime.now().add(const Duration(days: 10))),
      );

      expect(ctrl.upcomingTasks, isEmpty);
    });
  });

  // ── Group 11: generateId ───────────────────────────────────────────────────
  group('TaskController – generateId', () {
    test('returns a non-empty string', () {
      final ctrl = _buildController();
      expect(ctrl.generateId(), isNotEmpty);
    });

    test('two consecutive ids are different', () {
      final ctrl = _buildController();
      final id1 = ctrl.generateId();
      final id2 = ctrl.generateId();
      // isNot(equals(...)) — negates a matcher
      expect(id1, isNot(equals(id2)));
    });
  });
}
