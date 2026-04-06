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
  static const String resetPassword = '/api/v1/Auth/reset-password';

  // ── Groups ───────────────────────────────────────────
  static const String groups = '/api/v1/groups';
  static String groupById(String id) => '/api/v1/groups/$id';

  // ── Employees ─────────────────────────────────────────────
  static const String employees = '/api/v1/employees';
  static String employeeById(String id) => '/api/v1/employees/$id';

  // ── Task Items ────────────────────────────────────────────
  static const String taskItems = '/api/v1/task-items';
  static String taskItemById(String id) => '/api/v1/task-items/$id';
  static String taskItemAssign(String id) => '/api/v1/task-items/$id/assign';
  static String taskItemStatus(String id) => '/api/v1/task-items/$id/status';
  static String taskItemMembers(String taskItemId) =>
      '/api/v1/task-items/$taskItemId/members';
  static String taskItemMemberById(String taskItemId, String memberId) =>
      '/api/v1/task-items/$taskItemId/members/$memberId';
  static String taskItemProgresses(String taskItemId) =>
      '/api/v1/task-items/$taskItemId/progresses';
  static String taskItemProgressById(String taskItemId, String progressId) =>
      '/api/v1/task-items/$taskItemId/progresses/$progressId';
  static String taskItemComments(String taskItemId) =>
      '/api/v1/task-items/$taskItemId/comments';

  // ── Lookups ───────────────────────────────────────────────
  static const String lookupTaskPriorities = '/api/v1/lookups/task-priorities';
  static const String lookupTaskStatuses = '/api/v1/lookups/task-item-statuses';
  static const String lookupGenders = '/api/v1/lookups/genders';
  // ── Labels ────────────────────────────────────────────────
  static const String labels = '/api/v1/Labels';
  static String labelById(String id) => '/api/v1/Labels/$id';

  // ── Device Tokens ────────────────────────────────────────
  static const String deviceTokens = '/api/v1/device-tokens';

  // ── Notifications ────────────────────────────────────────
  static const String notifications = '/api/v1/notifications';
  static const String notificationsUnreadCount =
      '/api/v1/notifications/unread-count';
  static String notificationMarkRead(String id) =>
      '/api/v1/notifications/$id/read';
  static const String notificationsMarkAllRead =
      '/api/v1/notifications/read-all';
  static String notificationById(String id) => '/api/v1/notifications/$id';
}
