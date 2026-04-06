import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class DeleteTaskProgressUsecase {
  final TaskItemRepository _repo;
  const DeleteTaskProgressUsecase(this._repo);

  Future<void> call(String taskItemId, String progressId) =>
      _repo.deleteTaskProgress(taskItemId, progressId);
}