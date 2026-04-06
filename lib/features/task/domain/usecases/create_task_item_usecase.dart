import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class CreateTaskItemUsecase {
  final TaskItemRepository repository;
  CreateTaskItemUsecase(this.repository);
  Future<void> call(TaskItem taskItem) async {
    await repository.addTaskItem(taskItem);
  }
}