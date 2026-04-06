import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';

abstract interface class GroupRepository {
  Future<List<Group>> getAll();
  Future<Group> create({
    required String name,
    String? color,
    String? description,
  });
  Future<Group> update(
    String id, {
    required String name,
    String? color,
    String? description,
  });
  Future<void> delete(String id);
}
