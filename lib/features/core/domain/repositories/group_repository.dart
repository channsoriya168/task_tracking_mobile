import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';

abstract interface class TaskGroupRepository {
  Future<List<TaskGroup>> getAll();
  Future<TaskGroup> getById(String id);
  Future<TaskGroup> create({
    required String name,
    String? color,
    String? description,
  });
  Future<TaskGroup> update(
    String id, {
    required String name,
    String? color,
    String? description,
  });
  Future<void> delete(String id);
}
