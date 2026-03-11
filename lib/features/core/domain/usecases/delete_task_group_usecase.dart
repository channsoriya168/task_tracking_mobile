import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';

class DeleteTaskGroupUseCase {
  final TaskGroupRepository repository;

  DeleteTaskGroupUseCase(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
