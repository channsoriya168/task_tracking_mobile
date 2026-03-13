import 'package:task_tracking_mobile/features/core/domain/entities/lookup_item.dart';

/// Base model for any lookup that has only {id, name}.
/// Extend this for priority, status, etc.
abstract class LookupItemModel extends LookupItem {
  const LookupItemModel({required super.id, required super.name});

  static Map<String, dynamic> toBaseJson(LookupItem item) => {
        'id': item.id,
        'name': item.name,
      };
}