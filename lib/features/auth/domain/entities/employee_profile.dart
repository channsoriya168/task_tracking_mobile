class EmployeeProfile {
  const EmployeeProfile({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.roles,
    required this.employeeId,
    required this.email,
    required this.isActive,
    this.profileImageUrl,
    this.placeOfBirth,
    this.dateOfBirth,
    required this.taskGroups,
  });
  final String userId;
  final String fullName;
  final String phoneNumber;
  final List<String> roles;
  final String employeeId;
  final String email;
  final bool isActive;
  final String? profileImageUrl;
  final String? placeOfBirth;
  final DateTime? dateOfBirth;
  final List<dynamic> taskGroups;
  String get primaryRole => roles.isNotEmpty ? roles.first : '';
}
