import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';

class AuthModel {
  AuthModel._();

  static Auth fromJson(Map<String, dynamic> json) {
    return Auth(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      roles: _parseRoles(json['roles']) ?? [],
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      accessTokenExpiration: DateTime.parse(
        json['accessTokenExpiration'],
      ).toLocal(),
    );
  }

  static List<String>? _parseRoles(dynamic value) {
    if (value is! List) return null;
    return value.map((e) => e.toString()).toList();
  }
}
