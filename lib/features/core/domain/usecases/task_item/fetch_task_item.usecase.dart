import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class FetchTaskItemsUsecase {
  final TaskItemRepository _repository;

  FetchTaskItemsUsecase(this._repository);

  Future<List<TaskItem>> call() async {
    return await _repository.fetchTaskItems();
  }
}
