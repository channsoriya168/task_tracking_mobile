import 'package:task_tracking_mobile/features/core/data/datasources/remote/label_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/label_repository.dart';

class LabelRepositoryImpl implements LabelRepository {
  final LabelRemoteDatasource _remote;

  LabelRepositoryImpl(this._remote);

  @override
  Future<List<Label>> getAll() => _remote.getAll();

  @override
  Future<Label> create({required String name, String? description}) =>
      _remote.create(name: name, description: description);
}
