import 'package:task_tracking_mobile/features/label/data/label_remote_datasource.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';

class LabelRepositoryImpl implements LabelRepository {
  final LabelRemoteDatasource _remote;

  LabelRepositoryImpl(this._remote);

  @override
  Future<List<Label>> getAll() => _remote.getAll();

  @override
  Future<Label> create({required String name, String? description}) =>
      _remote.create(name: name, description: description);

  @override
  Future<Label> update(
    String id, {
    required String name,
    String? description,
  }) => _remote.update(id, name: name, description: description);

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
