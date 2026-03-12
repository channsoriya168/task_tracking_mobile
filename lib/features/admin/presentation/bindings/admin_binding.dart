import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/employee_repository.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminEmployeeController>(
      () => AdminEmployeeController(Get.find<EmployeeRepository>()),
    );
    Get.lazyPut<AdminTaskController>(() => AdminTaskController());
  }
}