import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_controller.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(() => TaskController());
  }
}