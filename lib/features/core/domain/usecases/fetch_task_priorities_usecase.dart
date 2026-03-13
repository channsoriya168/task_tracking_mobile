import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/lookup_repository.dart';

class FetchTaskPrioritiesUsecase {
  final LookupRepository _repository;

  FetchTaskPrioritiesUsecase(this._repository);

  Future<List<TaskPriority>> call() => _repository.fetchTaskPriorities();
}
