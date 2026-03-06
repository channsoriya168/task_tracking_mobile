import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class AdminTaskController extends GetxController {
  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final dashboardSelectedDate = Rxn<DateTime>();

  RxList<TaskModel> get tasks => Get.find<TaskController>().tasks;

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
      case 'Pending':
        result = result.where((t) => t.status == TaskStatus.todo).toList();
        break;
      case 'In Progress':
        result =
            result.where((t) => t.status == TaskStatus.inProgress).toList();
        break;
      case 'Complete':
        result = result.where((t) => t.status == TaskStatus.done).toList();
        break;
      case 'Fail':
        result = result.where((t) => t.status == TaskStatus.fail).toList();
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

  void deleteTask(String id) => Get.find<TaskController>().deleteTask(id);
}
