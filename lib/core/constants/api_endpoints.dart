/// All API endpoint paths relative to [BASE_URL].
/// Group by feature to keep them easy to find.
abstract class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────
  static const String login = '/identity/api/v1/Auth/login';
  static const String logout = '/tasktracking/api/v1/Auth/logout';
  static const String refreshToken = '/identity/api/v1/Auth/refresh-token';
  static const String profile = '/identity/api/v1/Auth/profile';
  static const String qrLogin = '/identity/api/v1/Auth/qr-login';
  static String generateQrLogin(String employeeId) =>
      '/tasktracking/api/v1/Auth/generate-qr-login/$employeeId';

  // ── Groups ───────────────────────────────────────────
  static const String groups = '/tasktracking/api/v1/groups';
  static String groupById(String id) => '/tasktracking/api/v1/groups/$id';

  // ── Employees ─────────────────────────────────────────────
  static const String employees = '/tasktracking/api/v1/employees';
  static String employeeById(String id) => '/tasktracking/api/v1/employees/$id';

  // ── Task Items ────────────────────────────────────────────
  static const String taskItems = '/tasktracking/api/v1/task-items';
  static String taskItemById(String id) =>
      '/tasktracking/api/v1/task-items/$id';
  static String taskItemAssign(String id) =>
      '/tasktracking/api/v1/task-items/$id/assign';
  static String taskItemStatus(String id) =>
      '/tasktracking/api/v1/task-items/$id/status';
  static String taskItemMembers(String taskItemId) =>
      '/tasktracking/api/v1/task-items/$taskItemId/members';
  static String taskItemMemberById(String taskItemId, String memberId) =>
      '/tasktracking/api/v1/task-items/$taskItemId/members/$memberId';
  static String taskItemProgresses(String taskItemId) =>
      '/tasktracking/api/v1/task-items/$taskItemId/progresses';
  static String taskItemProgressById(String taskItemId, String progressId) =>
      '/tasktracking/api/v1/task-items/$taskItemId/progresses/$progressId';
  static String taskItemComments(String taskItemId) =>
      '/tasktracking/api/v1/task-items/$taskItemId/comments';

  // ── Lookups ───────────────────────────────────────────────
  static const String lookupTaskPriorities =
      '/tasktracking/api/v1/lookups/task-priorities';
  static const String lookupTaskStatuses =
      '/tasktracking/api/v1/lookups/task-item-statuses';
  static const String lookupGenders = '/tasktracking/api/v1/lookups/genders';
  // ── Labels ────────────────────────────────────────────────
  static const String labels = '/tasktracking/api/v1/Labels';
  static String labelById(String id) => '/tasktracking/api/v1/Labels/$id';

  // ── Device Tokens ────────────────────────────────────────
  static const String deviceTokens = '/tasktracking/api/v1/device-tokens';

  // ── Notifications ────────────────────────────────────────
  static const String notifications = '/tasktracking/api/v1/notifications';
  static const String notificationsUnreadCount =
      '/tasktracking/api/v1/notifications/unread-count';
  static String notificationMarkRead(String id) =>
      '/tasktracking/api/v1/notifications/$id/read';
  static const String notificationsMarkAllRead =
      '/tasktracking/api/v1/notifications/read-all';
  static String notificationById(String id) =>
      '/tasktracking/api/v1/notifications/$id';
}
