import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

class TaskController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxInt navIndex = 0.obs;
  final RxString filterStatus = 'Todo'.obs;
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
        description:
            'Create wireframes and high-fidelity mockups for the new marketing website.',
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        category: 'Design',
        priority: TaskPriority.high,
        acceptedBy: 'Mike C.',
        assignedToId: 'staff1',
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
      ),
      TaskModel(
        id: '3',
        title: 'Write API documentation',
        description: 'Document all public endpoints for the v2 API release.',
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        category: 'Documentation',
        priority: TaskPriority.medium,
      ),
      TaskModel(
        id: '4',
        title: 'Team sync meeting',
        description: 'Weekly standup with the product and engineering team.',
        status: TaskStatus.done,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Meeting',
        priority: TaskPriority.low,
        acceptedBy: 'Emma D.',
        assignedToId: 'staff2',
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
        acceptedBy: 'James W.',
        assignedToId: 'staff3',
      ),
      TaskModel(
        id: '6',
        title: 'Update dependencies',
        description: 'Upgrade all packages to their latest stable versions.',
        status: TaskStatus.done,
        category: 'Maintenance',
        priority: TaskPriority.low,
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
      // Home page filter keys (display labels)
      case 'Pending':
      case 'Todo':
        result = result.where((t) => t.status == TaskStatus.todo).toList();
        break;
      case 'In Progress':
      case 'InProgress':
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

    result.sort((a, b) {
      if (a.status == TaskStatus.done && b.status != TaskStatus.done) return 1;
      if (a.status != TaskStatus.done && b.status == TaskStatus.done) return -1;
      if (a.dueDate != null && b.dueDate != null)
        return a.dueDate!.compareTo(b.dueDate!);
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return 0;
    });

    return result;
  }

  List<TaskModel> get pendingTasks =>
      tasks.where((t) => t.status == TaskStatus.todo).toList();

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 3));
    return tasks.where((t) {
      if (t.status == TaskStatus.done) return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(now.subtract(const Duration(hours: 1))) &&
          t.dueDate!.isBefore(soon);
    }).toList()..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  int get totalTasks => tasks.length;
  int get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.done).length;
  int get pendingCount =>
      tasks.where((t) => t.status == TaskStatus.todo).length;
  int get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get failCount => tasks.where((t) => t.status == TaskStatus.fail).length;

  // Aliases for task_page.dart compatibility
  int get todoCount => pendingCount;
  int get inReviewCount => inProgressTasks;

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
    final newStatus = task.status == TaskStatus.done
        ? TaskStatus.todo
        : TaskStatus.done;
    tasks[i] = task.copyWith(status: newStatus);
  }

  void acceptTask(String id, {String? description, String? acceptedBy}) {
    final i = tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    tasks[i] = tasks[i].copyWith(
      status: TaskStatus.inProgress,
      description: description ?? tasks[i].description,
      acceptedBy: acceptedBy ?? 'You',
    );
  }

  void finishTask(String id, {String? description}) {
    final i = tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    tasks[i] = tasks[i].copyWith(
      status: TaskStatus.done,
      description: description ?? tasks[i].description,
    );
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
