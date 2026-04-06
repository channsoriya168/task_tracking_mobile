import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_priority.dart';

class TaskItem {
  final String id;
  final String title;
  final String? description;

  /// UUID of the task group (position/department)
  final String? groupId;
  final String? groupName;

  /// UUID of the label
  final String? labelId;
  final String? labelName;

  /// Hex color string e.g. "#805AD5"
  final String? labelColor;

  final String? assignedToId;
  final String? assignedToName;
  final String? assignedToProfileImageUrl;
  final String? createdById;
  final String? createdByEmployeeName;
  final String? createdByProfileImageUrl;

  final TaskPriority priority;

  /// Current status — only {id, name} from task response (no nested transitions)
  final TaskStatusLookup status;

  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Valid next statuses for this task (from root-level allowedTransitions)
  final List<TaskStatusLookup> allowedTransitions;

  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    this.groupId,
    this.groupName,
    this.labelId,
    this.labelName,
    this.labelColor,
    this.assignedToId,
    this.assignedToName,
    this.assignedToProfileImageUrl,
    this.createdById,
    this.createdByEmployeeName,
    this.createdByProfileImageUrl,
    required this.priority,
    required this.status,
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.allowedTransitions = const [],
  });
}