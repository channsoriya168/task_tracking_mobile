import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class UpdateTaskItemStatusUsecase {
  final TaskItemRepository _repository;
  UpdateTaskItemStatusUsecase(this._repository);

  Future<void> call(String taskId, int status) =>
      _repository.updateTaskStatus(taskId, status);
}
