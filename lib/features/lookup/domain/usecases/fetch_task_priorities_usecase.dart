import 'package:task_tracking_mobile/features/lookup/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/lookup/domain/repositories/lookup_repository.dart';

class FetchTaskPrioritiesUsecase {
  final LookupRepository _repository;

  FetchTaskPrioritiesUsecase(this._repository);

  Future<List<TaskPriority>> call() => _repository.fetchTaskPriorities();
}
