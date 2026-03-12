import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/auth/data/models/auth_model.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';

// ── JWT helper ──────────────────────────────────────────────────────────────

/// Builds a minimal JWT with the given [exp] unix-timestamp (seconds).
String _makeJwt({required int exp}) {
  const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
  final payloadJson = '{"sub":"test","exp":$exp}';
  final payloadEncoded =
      base64Url.encode(utf8.encode(payloadJson)).replaceAll('=', '');
  return '$header.$payloadEncoded.fakesignature';
}

/// Unix timestamp ~100 years in the future — always non-expired in tests.
final int _futureExp =
    (DateTime.now().add(const Duration(days: 365 * 100)).millisecondsSinceEpoch /
            1000)
        .floor();

/// Unix timestamp in the distant past — always expired.
const int _pastExp = 1; // 1970-01-01

final _validJwt = _makeJwt(exp: _futureExp);
final _expiredJwt = _makeJwt(exp: _pastExp);
const _malformedJwt = 'not.a.valid.jwt';

// ── Helpers to build a minimal valid JSON response ──────────────────────────

Map<String, dynamic> _validJson({String? accessToken}) => {
      'userId': 'u1',
      'fullName': 'Alice Smith',
      'phoneNumber': '+85512345678',
      'roles': ['Manager'],
      'accessToken': accessToken ?? _validJwt,
      'refreshToken': 'rt_abc',
    };

void main() {
  // ────────────────────────────────────────────────────────────────────────────
  group('AuthModel.fromJson', () {
    test('maps all fields from a valid response', () {
      final auth = AuthModel.fromJson(_validJson());

      expect(auth.userId, 'u1');
      expect(auth.fullName, 'Alice Smith');
      expect(auth.phoneNumber, '+85512345678');
      expect(auth.roles, ['Manager']);
      expect(auth.accessToken, _validJwt);
      expect(auth.refreshToken, 'rt_abc');
    });

    test('derives accessTokenExpiration from JWT exp claim', () {
      final auth = AuthModel.fromJson(_validJson());
      final expectedExpiry =
          DateTime.fromMillisecondsSinceEpoch(_futureExp * 1000);

      // Allow a 1-second tolerance for integer rounding.
      expect(
        auth.accessTokenExpiration.difference(expectedExpiry).abs().inSeconds,
        lessThanOrEqualTo(1),
      );
    });

    test('falls back to +1 hour when JWT has no exp claim', () {
      final noExpPayload = base64Url
          .encode(utf8.encode('{"sub":"test"}'))
          .replaceAll('=', '');
      final jwt =
          'eyJhbGciOiJIUzI1NiJ9.$noExpPayload.fakesignature';

      final before = DateTime.now();
      final auth = AuthModel.fromJson(_validJson(accessToken: jwt));
      final after = DateTime.now();

      // Fallback adds 1 hour — expiry should be ~1 hour from now.
      final diff = auth.accessTokenExpiration.difference(before);
      expect(diff.inMinutes, greaterThanOrEqualTo(59));
      expect(auth.accessTokenExpiration.isBefore(after.add(const Duration(hours: 1, seconds: 5))),
          isTrue);
    });

    test('falls back to +1 hour when JWT is malformed', () {
      final before = DateTime.now();
      final auth = AuthModel.fromJson(_validJson(accessToken: _malformedJwt));
      final diff = auth.accessTokenExpiration.difference(before);
      expect(diff.inMinutes, greaterThanOrEqualTo(59));
    });

    test('uses empty string defaults when fields are null', () {
      final auth = AuthModel.fromJson({
        'accessToken': _validJwt,
      });

      expect(auth.userId, '');
      expect(auth.fullName, '');
      expect(auth.phoneNumber, '');
      expect(auth.roles, isEmpty);
      expect(auth.refreshToken, '');
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('AuthModel.toLocalJson', () {
    late Auth auth;

    setUp(() {
      auth = AuthModel.fromJson(_validJson());
    });

    test('contains userId, fullName, phoneNumber, roles', () {
      final map = AuthModel.toLocalJson(auth);

      expect(map['userId'], auth.userId);
      expect(map['fullName'], auth.fullName);
      expect(map['phoneNumber'], auth.phoneNumber);
      expect(map['roles'], auth.roles);
    });

    test('does not contain accessToken or refreshToken', () {
      final map = AuthModel.toLocalJson(auth);

      expect(map.containsKey('accessToken'), isFalse);
      expect(map.containsKey('refreshToken'), isFalse);
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('AuthModel.fromLocalJson', () {
    late Map<String, dynamic> localJson;

    setUp(() {
      final auth = AuthModel.fromJson(_validJson());
      localJson = AuthModel.toLocalJson(auth);
    });

    test('returns Auth when token is valid and not expired', () {
      final auth = AuthModel.fromLocalJson(localJson, _validJwt);

      expect(auth, isNotNull);
      expect(auth!.userId, 'u1');
      expect(auth.fullName, 'Alice Smith');
      expect(auth.phoneNumber, '+85512345678');
      expect(auth.roles, ['Manager']);
      expect(auth.accessToken, _validJwt);
    });

    test('returns null when token is expired', () {
      final auth = AuthModel.fromLocalJson(localJson, _expiredJwt);
      expect(auth, isNull);
    });

    test('returns null when token is malformed', () {
      final auth = AuthModel.fromLocalJson(localJson, _malformedJwt);
      expect(auth, isNull);
    });

    test('uses empty list for roles when missing from local json', () {
      localJson.remove('roles');
      final auth = AuthModel.fromLocalJson(localJson, _validJwt);
      expect(auth, isNotNull);
      expect(auth!.roles, isEmpty);
    });

    test('restored auth has empty refreshToken', () {
      final auth = AuthModel.fromLocalJson(localJson, _validJwt);
      expect(auth!.refreshToken, '');
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('Auth entity getters', () {
    test('avatarLetter returns first uppercase letter of fullName', () {
      final auth = AuthModel.fromJson(_validJson());
      expect(auth.avatarLetter, 'A');
    });

    test('avatarLetter returns ? when fullName is empty', () {
      final auth = AuthModel.fromJson({
        ...(_validJson()),
        'fullName': '',
      });
      expect(auth.avatarLetter, '?');
    });

    test('primaryRole returns the first role', () {
      final auth = AuthModel.fromJson(_validJson());
      expect(auth.primaryRole, 'Manager');
    });

    test('primaryRole returns empty string when roles list is empty', () {
      final auth = AuthModel.fromJson({
        ...(_validJson()),
        'roles': <dynamic>[],
      });
      expect(auth.primaryRole, '');
    });
  });
}
