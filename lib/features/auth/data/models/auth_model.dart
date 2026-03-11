import 'dart:convert';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';

class AuthModel extends Auth {
  AuthModel({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required List<String> roles,
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiration,
  }) : super(
         userId: userId,
         fullName: fullName,
         phoneNumber: phoneNumber,
         roles: roles,
         accessToken: accessToken,
         refreshToken: refreshToken,
         accessTokenExpiration: accessTokenExpiration,
       );

  static Auth fromJson(Map<String, dynamic> json) {
    final roles =
        (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    final accessToken = json['accessToken'] as String? ?? '';

    // API does not return accessTokenExpiration — extract from JWT exp claim
    final expiry = _expiryFromJwt(accessToken) ?? DateTime.now().add(const Duration(hours: 1));

    return Auth(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      roles: roles,
      accessToken: accessToken,
      refreshToken: json['refreshToken'] as String? ?? '',
      accessTokenExpiration: expiry,
    );
  }

  /// Decodes the JWT payload and returns the [exp] claim as [DateTime].
  /// Returns null if the token is malformed.
  static DateTime? _expiryFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Base64url → base64 padding
      var payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);

      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload))) as Map<String, dynamic>;
      final exp = decoded['exp'] as int?;
      if (exp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (_) {
      return null;
    }
  }

  /// Minimal snapshot saved to local storage.
  /// Only non-sensitive user info — token is stored separately.
  static Map<String, dynamic> toLocalJson(Auth auth) => {
    'userId': auth.userId,
    'fullName': auth.fullName,
    'phoneNumber': auth.phoneNumber,
    'roles': auth.roles,
  };

  /// Restore [Auth] from local storage snapshot + stored token.
  /// Returns null if the stored token is already expired.
  static Auth? fromLocalJson(Map<String, dynamic> json, String accessToken) {
    final roles =
        (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    // Re-derive expiry from the stored JWT — no need to persist it separately
    final expiry = _expiryFromJwt(accessToken);
    if (expiry == null || expiry.isBefore(DateTime.now())) return null;

    return Auth(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      roles: roles,
      accessToken: accessToken,
      refreshToken: '',
      accessTokenExpiration: expiry,
    );
  }
}
