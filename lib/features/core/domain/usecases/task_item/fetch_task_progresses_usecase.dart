import 'package:task_tracking_mobile/features/core/domain/entities/task_progress.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class FetchTaskProgressesUsecase {
  final TaskItemRepository _repo;
  const FetchTaskProgressesUsecase(this._repo);

  Future<List<TaskProgress>> call(String taskItemId) =>
      _repo.fetchTaskProgresses(taskItemId);
}
