import 'package:task_tracking_mobile/features/core/domain/repositories/group_repository.dart';

class DeleteGroupUseCase {
  final GroupRepository repository;

  DeleteGroupUseCase(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
