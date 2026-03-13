/// All API endpoint paths relative to [BASE_URL].
/// Group by feature to keep them easy to find.
abstract class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────
  static const String login = '/api/v1/Auth/login';
  static const String logout = '/api/v1/Auth/logout';
  static const String refreshToken = '/api/v1/Auth/refresh-token';
  static const String profile = '/api/v1/Auth/profile';
  static const String changePassword = '/api/v1/Auth/change-password';

  // ── Task Groups ───────────────────────────────────────────
  static const String taskGroups = '/api/v1/task-groups';
  static String taskGroupById(String id) => '/api/v1/task-groups/$id';

  // ── Employees ─────────────────────────────────────────────
  static const String employees = '/api/v1/employees';
  static String employeeById(String id) => '/api/v1/employees/$id';

  // ── Task Items ────────────────────────────────────────────
  static const String taskItems = '/api/v1/task-items';
  static String taskItemById(String id) => '/api/v1/task-items/$id';

  // ── Lookups ───────────────────────────────────────────────
  static const String lookupTaskPriorities = '/api/v1/lookups/task-priorities';
  static const String lookupTaskStatuses = '/api/v1/lookups/task-statuses';
  // ── Labels ────────────────────────────────────────────────
  static const String labels = '/api/v1/Labels';
  static String labelById(String id) => '/api/v1/Labels/$id';
}
