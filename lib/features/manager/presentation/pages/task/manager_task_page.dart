import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/lookup_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/create_task_group_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/fetch_task_priorities_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/get_all_task_groups_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/create_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/delete_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/fetch_task_item.usecase.dart';
import 'package:task_tracking_mobile/features/core/domain/usecases/task_item/update_task_item_usecase.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/task/manager_task_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/task/manager_task_tablet_page.dart';

class ManagerTaskPage extends StatefulWidget {
  const ManagerTaskPage({super.key});

  @override
  State<ManagerTaskPage> createState() => _ManagerTaskPageState();
}

class _ManagerTaskPageState extends State<ManagerTaskPage> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ManagerTaskController>()) {
      Get.put<ManagerTaskController>(
        ManagerTaskController(
          FetchTaskItemsUsecase(Get.find<TaskItemRepository>()),
          CreateTaskItemUsecase(Get.find<TaskItemRepository>()),
          UpdateTaskItemUsecase(Get.find<TaskItemRepository>()),
          DeleteTaskItemUsecase(Get.find<TaskItemRepository>()),
          FetchTaskPrioritiesUsecase(Get.find<LookupRepository>()),
        ),
      );
    }
    if (!Get.isRegistered<TaskGroupController>()) {
      Get.put<TaskGroupController>(
        TaskGroupController(
          GetAllTaskGroupsUseCase(Get.find<TaskGroupRepository>()),
          CreateTaskGroupUseCase(Get.find<TaskGroupRepository>()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const ManagerTaskMobilePage();
    }
    return const ManagerTaskTabletPage();
  }
}
