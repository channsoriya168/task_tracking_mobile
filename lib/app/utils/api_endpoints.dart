/// All API endpoint paths relative to [BASE_URL].
/// Group by feature to keep them easy to find.
abstract class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────
  static const String login = '/api/v1/Auth/login';
  static const String logout = '/api/v1/Auth/logout';
  static const String me = '/api/v1/Auth/me';

  // ── Task Groups ───────────────────────────────────────────
  static const String taskGroups = '/api/v1/task-groups';
  static String taskGroupById(String id) => '/api/v1/task-groups/$id';

  // ── Employees ─────────────────────────────────────────────
  static const String employees = '/api/v1/employees';
}
