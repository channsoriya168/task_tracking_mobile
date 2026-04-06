import 'package:task_tracking_mobile/features/lookup/domain/entities/lookup_gender.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_priority.dart';

abstract interface class LookupRepository {
  Future<List<TaskPriority>> fetchTaskPriorities();
  Future<List<TaskStatusLookup>> fetchTaskStatuses();
  Future<List<LookupGender>> fetchGenders();
}
