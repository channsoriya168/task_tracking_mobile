import 'package:get/get.dart';
import 'package:task_tracking_mobile/data/models/task_model.dart';

class TaskController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxInt navIndex = 0.obs;
  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;

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
        description: 'Create wireframes and high-fidelity mockups for the new marketing website.',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        category: 'Design',
      ),
      TaskModel(
        id: '2',
        title: 'Fix authentication bug',
        description: 'Users are getting logged out unexpectedly on mobile devices after 10 minutes.',
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(hours: 6)),
        category: 'Engineering',
      ),
      TaskModel(
        id: '3',
        title: 'Write API documentation',
        description: 'Document all public endpoints for the v2 API release.',
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        category: 'Documentation',
      ),
      TaskModel(
        id: '4',
        title: 'Team sync meeting',
        description: 'Weekly standup with the product and engineering team.',
        priority: TaskPriority.low,
        status: TaskStatus.done,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Meeting',
      ),
      TaskModel(
        id: '5',
        title: 'Performance optimization',
        description: 'Reduce app cold startup time by 40% through lazy loading.',
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        category: 'Engineering',
      ),
      TaskModel(
        id: '6',
        title: 'Update dependencies',
        description: 'Upgrade all packages to their latest stable versions.',
        priority: TaskPriority.low,
        status: TaskStatus.done,
        category: 'Maintenance',
      ),
      TaskModel(
        id: '7',
        title: 'User research interviews',
        description: 'Conduct 5 user interviews to validate the new onboarding flow.',
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        category: 'Research',
      ),
    ]);
  }

  List<TaskModel> get filteredTasks {
    var result = tasks.toList();

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
      }).toList();
    }

    switch (filterStatus.value) {
      case 'Active':
        result = result.where((t) => t.status != TaskStatus.done).toList();
        break;
      case 'Done':
        result = result.where((t) => t.status == TaskStatus.done).toList();
        break;
    }

    // Sort: todo/inProgress first, done last; then by due date
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

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 3));
    return tasks.where((t) {
      if (t.status == TaskStatus.done) return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(now.subtract(const Duration(hours: 1))) &&
          t.dueDate!.isBefore(soon);
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.status == TaskStatus.done).length;
  int get inProgressTasks => tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get highPriorityTasks =>
      tasks.where((t) => t.priority == TaskPriority.high && t.status != TaskStatus.done).length;

  double get completionRate {
    if (tasks.isEmpty) return 0;
    return completedTasks / tasks.length;
  }

  void addTask(TaskModel task) => tasks.add(task);

  void updateTask(TaskModel updated) {
    final i = tasks.indexWhere((t) => t.id == updated.id);
    if (i != -1) tasks[i] = updated;
  }

  void deleteTask(String id) => tasks.removeWhere((t) => t.id == id);

  void toggleComplete(String id) {
    final i = tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final task = tasks[i];
    final newStatus = task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
    tasks[i] = task.copyWith(status: newStatus);
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}