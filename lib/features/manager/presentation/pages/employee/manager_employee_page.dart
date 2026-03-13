import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/image_service.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/pick_and_compress_image_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/employee/manager_employee_tablet_page.dart';

class ManagerEmployeePage extends StatefulWidget {
  const ManagerEmployeePage({super.key});

  @override
  State<ManagerEmployeePage> createState() => _ManagerEmployeePageState();
}

class _ManagerEmployeePageState extends State<ManagerEmployeePage> {
  @override
  void initState() {
    super.initState();
    // Image services — required by EmployeeController's field initializer
    if (!Get.isRegistered<ImageService>()) {
      Get.put(ImageService());
    }
    if (!Get.isRegistered<PickAndCompressImageUseCase>()) {
      Get.put(PickAndCompressImageUseCase(Get.find()));
    }
    // TaskGroupController — required by EmployeeController.positions getter
    if (!Get.isRegistered<TaskGroupController>()) {
      Get.put<TaskGroupController>(
        TaskGroupController(
          GetAllTaskGroupsUseCase(Get.find<TaskGroupRepository>()),
          CreateTaskGroupUseCase(Get.find<TaskGroupRepository>()),
        ),
      );
    }
    if (!Get.isRegistered<EmployeeController>()) {
      Get.put<EmployeeController>(EmployeeController());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const ManagerEmployeeMobilePage();
    }
    return const ManagerEmployeeTabletPage();
  }
}
