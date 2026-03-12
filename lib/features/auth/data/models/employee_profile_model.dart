import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';

class EmployeeProfileModel extends EmployeeProfile {
  const EmployeeProfileModel({
    required super.employeeId,
    required super.email,
    required super.isActive,
    super.profileImageUrl,
    super.placeOfBirth,
    super.dateOfBirth,
    required super.taskGroups,
    required super.userId,
    required super.fullName,
    required super.phoneNumber,
    required super.roles,
  });

  static EmployeeProfile? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final employee = json['employee'] as Map<String, dynamic>? ?? {};
    return EmployeeProfileModel(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
      employeeId: employee['employeeId'] as String? ?? '',
      email: employee['email'] as String? ?? '',
      isActive: employee['isActive'] as bool? ?? false,
      profileImageUrl: employee['profileImageUrl'] as String?,
      placeOfBirth: employee['placeOfBirth'] as String?,
      dateOfBirth: employee['dateOfBirth'] != null
          ? DateTime.tryParse(employee['dateOfBirth'] as String)
          : null,
      taskGroups: (employee['taskGroups'] as List<dynamic>?) ?? [],
    );
  }
}
