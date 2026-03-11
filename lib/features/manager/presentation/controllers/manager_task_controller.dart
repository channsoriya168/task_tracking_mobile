import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';

class ManagerTaskController extends GetxController {
  final RxList<TaskItem> tasks = <TaskItem>[].obs;
  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final titleTextEditor = TextEditingController();
  final descTextEditor = TextEditingController();
  final selectedCategory = 'Engineering'.obs;
  final selectedDueDate = Rxn<DateTime>();
  final dashboardSelectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    tasks.addAll([
      TaskItem(
        id: '1',
        title: 'Design new landing page',
        description:
            'Create wireframes and high-fidelity mockups for the new marketing website.',
        status: TaskItemStatus.inProgress,
        priority: TaskItemPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        groupName: 'Design',
        assignedToName: 'Alice J.',
        assignedToId: 'e1',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '2',
        title: 'Fix authentication bug',
        description:
            'Users are getting logged out unexpectedly on mobile devices after 10 minutes.',
        status: TaskItemStatus.todo,
        priority: TaskItemPriority.high,
        dueDate: DateTime.now().add(const Duration(hours: 6)),
        groupName: 'Engineering',
        assignedToId: 'e1',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '3',
        title: 'Write API documentation',
        description: 'Document all public endpoints for the v2 API release.',
        status: TaskItemStatus.todo,
        priority: TaskItemPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        groupName: 'Documentation',
        assignedToId: 'e2',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '4',
        title: 'Team sync meeting',
        description: 'Weekly standup with the product and engineering team.',
        status: TaskItemStatus.done,
        priority: TaskItemPriority.low,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        groupName: 'Meeting',
        assignedToName: 'Bob S.',
        assignedToId: 'e2',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '5',
        title: 'Performance optimization',
        description:
            'Reduce app cold startup time by 40% through lazy loading.',
        status: TaskItemStatus.inProgress,
        priority: TaskItemPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        groupName: 'Engineering',
        assignedToName: 'Charlie B.',
        assignedToId: 'e3',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '6',
        title: 'Update dependencies',
        description: 'Upgrade all packages to their latest stable versions.',
        status: TaskItemStatus.done,
        priority: TaskItemPriority.low,
        groupName: 'Maintenance',
        assignedToId: 'e3',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '7',
        title: 'User research interviews',
        description:
            'Conduct 5 user interviews to validate the new onboarding flow.',
        status: TaskItemStatus.todo,
        priority: TaskItemPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        groupName: 'Research',
        assignedToId: 'e4',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '8',
        title: 'Deploy to production',
        description:
            'Run deployment pipeline and verify all services are healthy.',
        status: TaskItemStatus.fail,
        priority: TaskItemPriority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        groupName: 'Engineering',
        assignedToId: 'e4',
        labelId: '',
        createdById: '',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  List<TaskItem> get filteredTasks {
    var result = tasks.toList();

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(q) ||
            (t.description ?? '').toLowerCase().contains(q) ||
            (t.groupName ?? '').toLowerCase().contains(q);
      }).toList();
    }

    switch (filterStatus.value) {
      case 'Pending':
        result = result.where((t) => t.status == TaskItemStatus.todo).toList();
        break;
      case 'In Progress':
        result = result
            .where((t) => t.status == TaskItemStatus.inProgress)
            .toList();
        break;
      case 'Complete':
        result = result.where((t) => t.status == TaskItemStatus.done).toList();
        break;
      case 'Fail':
        result = result.where((t) => t.status == TaskItemStatus.fail).toList();
        break;
    }

    final sel = dashboardSelectedDate.value;
    if (sel != null) {
      result = result.where((t) {
        if (t.dueDate == null) return false;
        final d = t.dueDate!;
        return d.year == sel.year && d.month == sel.month && d.day == sel.day;
      }).toList();
    }

    result.sort((a, b) {
      if (a.status == TaskItemStatus.done && b.status != TaskItemStatus.done)
        return 1;
      if (a.status != TaskItemStatus.done && b.status == TaskItemStatus.done)
        return -1;
      if (a.dueDate != null && b.dueDate != null)
        return a.dueDate!.compareTo(b.dueDate!);
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
        return tasks.where((t) => t.status == TaskItemStatus.todo).length;
      case 'In Progress':
        return tasks.where((t) => t.status == TaskItemStatus.inProgress).length;
      case 'Complete':
        return tasks.where((t) => t.status == TaskItemStatus.done).length;
      case 'Fail':
        return tasks.where((t) => t.status == TaskItemStatus.fail).length;
      default:
        return 0;
    }
  }

  void createTask() {
    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleTextEditor.text.trim(),
      description: descTextEditor.text.trim(),
      groupName: selectedCategory.value,
      dueDate: selectedDueDate.value,
      status: TaskItemStatus.todo,
      priority: TaskItemPriority.medium,
      labelId: '',
      createdById: '',
      createdAt: DateTime.now(),
    );
    tasks.add(newTask);
  }

  void updateTask(TaskItem updated) {
    final i = tasks.indexWhere((t) => t.id == updated.id);
    if (i != -1) tasks[i] = updated;
  }

  void deleteTask(String id) => tasks.removeWhere((t) => t.id == id);

  // Color (String? category) {
  //   if (category == null || category.isEmpty) return kTextMuted;
  //   try {
  //     return listPosition
  //         .firstWhere((p) => p.name.toLowerCase() == category.toLowerCase())
  //         .color;
  //   } catch (_) {
  //     return kTextMuted;
  //   }
  // }
}
