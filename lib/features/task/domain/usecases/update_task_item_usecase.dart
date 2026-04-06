import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class UpdateTaskItemUsecase {
  final TaskItemRepository _repository;

  UpdateTaskItemUsecase(this._repository);

  Future<void> call(TaskItem taskItem) async {
    await _repository.updateTaskItem(taskItem);
  }
}