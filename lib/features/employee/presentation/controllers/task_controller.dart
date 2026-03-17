import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/employee/data/models/task_model.dart';

class TaskController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxInt navIndex = 0.obs;
  final RxString filterStatus = 'Todo'.obs;
  final RxString searchQuery = ''.obs;

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
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
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
