import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/data/datasources/remote/task_group_remote_datasource.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_group_model.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_group_repository.dart';

class TaskGroupRepositoryImpl implements TaskGroupRepository {
  final TaskGroupRemoteDatasource _remote;

  TaskGroupRepositoryImpl(this._remote);

  @override
  Future<List<TaskGroup>> getAll() async {
    try {
      return await _remote.getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<TaskGroup> getById(String id) async {
    try {
      return await _remote.getById(id);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<TaskGroup> create({
    required String name,
    String? color,
    String? description,
  }) async {
    try {
      final model = TaskGroupModel(
        id: '',
        name: name,
        color: color != null ? _parseColor(color) : null,
        description: description,
        createdAt: DateTime.now(),
      );
      return await _remote.create(model);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<TaskGroup> update(
    String id, {
    required String name,
    String? color,
    String? description,
  }) async {
    try {
      final model = TaskGroupModel(
        id: id,
        name: name,
        color: color != null ? _parseColor(color) : null,
        description: description,
        createdAt: DateTime.now(),
      );
      return await _remote.update(id, model);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remote.delete(id);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Color? _parseColor(String hex) {
    final sanitized = hex.replaceAll('#', '');
    final value = int.tryParse(
      sanitized.length == 6 ? 'FF$sanitized' : sanitized,
      radix: 16,
    );
    return value != null ? Color(value) : null;
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your connection.';
    }
    final status = e.response?.statusCode;
    if (status == 400) {
      return e.response?.data?['message'] as String? ?? 'Invalid request.';
    }
    if (status == 401) return 'Unauthorized.';
    if (status == 403) return 'Access denied.';
    if (status == 404) return 'Task group not found.';
    if (status == 500) return 'Server error. Please try again later.';
    return e.response?.data?['message'] as String? ??
        e.message ??
        'Something went wrong.';
  }
}
