import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/data/models/position_model.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_model.dart';

class ManagerTaskController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final titleTextEditor = TextEditingController();
  final descTextEditor = TextEditingController();
  final selectedCategory = 'Engineering'.obs;
  final selectedDueDate = Rxn<DateTime>();
  // Dashboard date filter (week calendar selection)
  final dashboardSelectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    tasks.addAll([
      TaskModel(
        id: '1',
        title: 'Design new landing page',
        description:
            'Create wireframes and high-fidelity mockups for the new marketing website.',
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        category: 'Design',
        priority: TaskPriority.high,
        acceptedBy: 'Alice J.',
        assignedToId: 'e1',
      ),
      TaskModel(
        id: '2',
        title: 'Fix authentication bug',
        description:
            'Users are getting logged out unexpectedly on mobile devices after 10 minutes.',
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(hours: 6)),
        category: 'Engineering',
        priority: TaskPriority.high,
        assignedToId: 'e1',
      ),
      TaskModel(
        id: '3',
        title: 'Write API documentation',
        description: 'Document all public endpoints for the v2 API release.',
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        category: 'Documentation',
        priority: TaskPriority.medium,
        assignedToId: 'e2',
      ),
      TaskModel(
        id: '4',
        title: 'Team sync meeting',
        description: 'Weekly standup with the product and engineering team.',
        status: TaskStatus.done,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Meeting',
        priority: TaskPriority.low,
        acceptedBy: 'Bob S.',
        assignedToId: 'e2',
      ),
      TaskModel(
        id: '5',
        title: 'Performance optimization',
        description:
            'Reduce app cold startup time by 40% through lazy loading.',
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        category: 'Engineering',
        priority: TaskPriority.medium,
        acceptedBy: 'Charlie B.',
        assignedToId: 'e3',
      ),
      TaskModel(
        id: '6',
        title: 'Update dependencies',
        description: 'Upgrade all packages to their latest stable versions.',
        status: TaskStatus.done,
        category: 'Maintenance',
        priority: TaskPriority.low,
        assignedToId: 'e3',
      ),
      TaskModel(
        id: '7',
        title: 'User research interviews',
        description:
            'Conduct 5 user interviews to validate the new onboarding flow.',
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        category: 'Research',
        priority: TaskPriority.medium,
        assignedToId: 'e4',
      ),
      TaskModel(
        id: '8',
        title: 'Deploy to production',
        description:
            'Run deployment pipeline and verify all services are healthy.',
        status: TaskStatus.fail,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Engineering',
        priority: TaskPriority.high,
        assignedToId: 'e4',
      ),
    ]);
  }

  List<TaskModel> get filteredTasks {
    var result = tasks.toList();

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
      }).toList();
    }

    // Status filter
    switch (filterStatus.value) {
      case 'Pending':
        result = result.where((t) => t.status == TaskStatus.todo).toList();
        break;
      case 'In Progress':
        result = result
            .where((t) => t.status == TaskStatus.inProgress)
            .toList();
        break;
      case 'Complete':
        result = result.where((t) => t.status == TaskStatus.done).toList();
        break;
      case 'Fail':
        result = result.where((t) => t.status == TaskStatus.fail).toList();
        break;
    }

    // Date filter (dashboard week calendar)
    final sel = dashboardSelectedDate.value;
    if (sel != null) {
      result = result.where((t) {
        if (t.dueDate == null) return false;
        final d = t.dueDate!;
        return d.year == sel.year && d.month == sel.month && d.day == sel.day;
      }).toList();
    }

    result.sort((a, b) {
      if (a.status == TaskStatus.done && b.status != TaskStatus.done) return 1;
      if (a.status != TaskStatus.done && b.status == TaskStatus.done) return -1;
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return 0;
    });

    return result;
  }

  int countByStatus(String status) {
    switch (status) {
      case 'All':
        return tasks.length;
      case 'Pending':
        return tasks.where((t) => t.status == TaskStatus.todo).length;
      case 'In Progress':
        return tasks.where((t) => t.status == TaskStatus.inProgress).length;
      case 'Complete':
        return tasks.where((t) => t.status == TaskStatus.done).length;
      case 'Fail':
        return tasks.where((t) => t.status == TaskStatus.fail).length;
      default:
        return 0;
    }
  }

  void createTask() {
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleTextEditor.text.trim(),
      description: descTextEditor.text.trim(),
      category: selectedCategory.value,
      dueDate: selectedDueDate.value,
    );
    tasks.add(newTask);
  }

  void updateTask(TaskModel updated) {
    final i = tasks.indexWhere((t) => t.id == updated.id);
    if (i != -1) tasks[i] = updated;
  }

  void deleteTask(String id) => tasks.removeWhere((t) => t.id == id);

  Color positionColor(String category) {
    try {
      return listPosition
          .firstWhere((p) => p.name.toLowerCase() == category.toLowerCase())
          .color;
    } catch (_) {
      return kTextMuted;
    }
  }
}
