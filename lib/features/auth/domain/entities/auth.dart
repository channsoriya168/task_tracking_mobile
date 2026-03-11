class Auth {
  const Auth({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.roles,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiration,
  });

  final String userId;
  final String fullName;
  final String phoneNumber;
  final List<String> roles;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiration;

  String get avatarLetter =>
      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  String get primaryRole =>
      roles.isNotEmpty ? roles.first : '';
}
