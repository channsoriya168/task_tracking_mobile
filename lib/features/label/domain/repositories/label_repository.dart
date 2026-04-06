import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';

abstract class LabelRepository {
  Future<List<Label>> getAll();
  Future<Label> create({required String name, String? description});
  Future<Label> update(String id, {required String name, String? description});
  Future<void> delete(String id);
}
