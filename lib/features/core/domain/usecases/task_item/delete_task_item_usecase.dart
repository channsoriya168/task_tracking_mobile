import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class DeleteTaskItemUsecase {
  final TaskItemRepository _repository;

  DeleteTaskItemUsecase(this._repository);

  Future<void> call(TaskItem taskItem) async {
    await _repository.deleteTaskItem(taskItem);
  }
}
