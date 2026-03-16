import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class FetchTaskItemByIdUsecase {
  final TaskItemRepository _repository;

  FetchTaskItemByIdUsecase(this._repository);

  Future<TaskItem> call(String id) => _repository.fetchTaskItemById(id);
}
