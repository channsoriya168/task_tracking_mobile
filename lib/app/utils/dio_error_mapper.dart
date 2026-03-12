import 'package:dio/dio.dart';

/// Maps a [DioException] to a human-readable error message.
/// Use this across all repository implementations instead of duplicating error handling.
String mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Connection timed out. Please try again.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Unable to reach the server. Check your connection.';
  }
  final status = e.response?.statusCode;
  if (status == 400) {
    return e.response?.data?['message'] as String? ?? 'Invalid credentials.';
  }
  if (status == 401) return 'Incorrect phone number or password.';
  if (status == 403) return 'Access denied.';
  if (status == 500) return 'Server error. Please try again later.';
  return e.response?.data?['message'] as String? ??
      e.message ??
      'Something went wrong.';
}