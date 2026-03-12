import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';

abstract class LabelRepository {
  Future<List<Label>> getAll();
  Future<Label> create({required String name, String? description});
}
