import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/group_repository.dart';

class GetAllGroupsUseCase {
  final GroupRepository repository;

  GetAllGroupsUseCase(this.repository);

  Future<List<Group>> call() => repository.getAll();
}
