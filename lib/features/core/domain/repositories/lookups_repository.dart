import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';

abstract interface class LookupsRepository {
  Future<List<TaskStatusLookup>> fetchTaskItemStatuses();
}
