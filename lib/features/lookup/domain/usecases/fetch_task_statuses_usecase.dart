import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/lookup/domain/repositories/lookup_repository.dart';

class FetchTaskStatusesUsecase {
  final LookupRepository _repository;

  FetchTaskStatusesUsecase(this._repository);

  Future<List<TaskStatusLookup>> call() => _repository.fetchTaskStatuses();
}
