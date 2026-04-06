import 'package:dio/dio.dart';
import 'package:task_tracking_mobile/core/network/api_client.dart';
import 'package:task_tracking_mobile/core/network/api_endpoints.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_item_model.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_comment_model.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_member_model.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_progress_model.dart';

class TaskItemRemoteDatasource {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<TaskItemModel>> getAll({
    String? search,
    int? statusId,
    String? groupId,
    DateTime? SelectedDate,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['Search'] = search;
    if (statusId != null) params['Status'] = statusId;
    if (groupId != null && groupId.isNotEmpty) params['GroupId'] = groupId;
    if (SelectedDate != null) {
      params['SelectedDate'] =
          '${SelectedDate.year.toString().padLeft(4, '0')}-'
          '${SelectedDate.month.toString().padLeft(2, '0')}-'
          '${SelectedDate.day.toString().padLeft(2, '0')}';
    }

    final response = await _dio.get(
      ApiEndpoints.taskItems,
      queryParameters: params.isEmpty ? null : params,
    );
    return (response.data as List)
        .map((e) => TaskItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(TaskItemModel taskItem) async {
    await _dio.post(ApiEndpoints.taskItems, data: taskItem.toJson());
  }

  Future<TaskItemModel> update(String id, TaskItemModel taskItem) async {
    final response = await _dio.put(
      ApiEndpoints.taskItemById(id),
      data: taskItem.toJson(),
    );
    return TaskItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.taskItemById(id));
  }

  Future<TaskItemModel> getById(String id) async {
    final response = await _dio.get(ApiEndpoints.taskItemById(id));
    return TaskItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> assignTask(String id, String assignedToId) async {
    await _dio.patch(
      ApiEndpoints.taskItemAssign(id),
      data: {'assignedToId': assignedToId},
    );
  }

  Future<void> updateStatus(String id, int status) async {
    await _dio.patch(ApiEndpoints.taskItemStatus(id), data: {'status': status});
  }

  Future<List<TaskMemberModel>> getTaskMembers(String taskItemId) async {
    final response = await _dio.get(ApiEndpoints.taskItemMembers(taskItemId));
    return (response.data as List)
        .map((e) => TaskMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTaskMember(String taskItemId, String employeeId) async {
    await _dio.post(
      ApiEndpoints.taskItemMembers(taskItemId),
      data: {'employeeId': employeeId},
    );
  }

  Future<void> removeTaskMember(String taskItemId, String memberId) async {
    await _dio.delete(ApiEndpoints.taskItemMemberById(taskItemId, memberId));
  }

  // ── Comments ──────────────────────────────────────────────────────────────

  Future<List<TaskCommentModel>> getTaskComments(String taskItemId) async {
    final response = await _dio.get(ApiEndpoints.taskItemComments(taskItemId));
    final raw = response.data;
    final List dataList;
    if (raw is List) {
      dataList = raw;
    } else if (raw is Map) {
      final inner = raw['items'] ?? raw['data'] ?? raw['comments'];
      dataList = inner is List ? inner : [];
    } else {
      dataList = [];
    }
    return dataList
        .map((e) => TaskCommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTaskComment(
    String taskItemId, {
    required String content,
    String? parentCommentId,
  }) async {
    final body = <String, dynamic>{'content': content};
    if (parentCommentId != null) body['parentCommentId'] = parentCommentId;
    await _dio.post(ApiEndpoints.taskItemComments(taskItemId), data: body);
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Future<List<TaskProgressModel>> getTaskProgresses(String taskItemId) async {
    final response = await _dio.get(
      ApiEndpoints.taskItemProgresses(taskItemId),
    );
    final raw = response.data;
    // Guard: API may return null or a wrapped object instead of a plain array
    final List dataList;
    if (raw is List) {
      dataList = raw;
    } else if (raw is Map) {
      final inner = raw['items'] ?? raw['data'] ?? raw['progresses'];
      dataList = inner is List ? inner : [];
    } else {
      dataList = [];
    }
    return dataList
        .map((e) => TaskProgressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTaskProgress(
    String taskItemId, {
    required int progressPercentage,
    required DateTime loggedAt,
    String? notes,
    double? hoursWorked,
    int? status,
  }) async {
    final body = CreateProgressBody(
      progressPercentage: progressPercentage,
      loggedAt: loggedAt,
      notes: notes,
      hoursWorked: hoursWorked,
      status: status,
    );
    await _dio.post(
      ApiEndpoints.taskItemProgresses(taskItemId),
      data: body.toJson(),
    );
  }

  Future<void> updateTaskProgress(
    String taskItemId,
    String progressId, {
    required int progressPercentage,
    required DateTime loggedAt,
    required String notes,
    double? hoursWorked,
    int? status,
  }) async {
    final body = CreateProgressBody(
      progressPercentage: progressPercentage,
      loggedAt: loggedAt,
      notes: notes,
      hoursWorked: hoursWorked,
      status: status,
    );
    await _dio.put(
      ApiEndpoints.taskItemProgressById(taskItemId, progressId),
      data: body.toJson(),
    );
  }

  Future<void> deleteTaskProgress(String taskItemId, String progressId) async {
    await _dio.delete(
      ApiEndpoints.taskItemProgressById(taskItemId, progressId),
    );
  }
}
