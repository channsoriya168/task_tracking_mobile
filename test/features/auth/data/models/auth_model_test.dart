import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/auth/data/models/auth_model.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _futureExpiration = '2099-12-31T00:00:00.000Z';

Map<String, dynamic> _validJson({String? expiration}) => {
      'userId': 'u1',
      'fullName': 'Alice Smith',
      'phoneNumber': '+85512345678',
      'roles': ['Manager'],
      'accessToken': 'access_token_abc',
      'refreshToken': 'refresh_token_xyz',
      'accessTokenExpiration': expiration ?? _futureExpiration,
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
      expect(auth.accessToken, 'access_token_abc');
      expect(auth.refreshToken, 'refresh_token_xyz');
    });

    test('parses accessTokenExpiration from ISO 8601 string', () {
      final auth = AuthModel.fromJson(_validJson());
      final expected = DateTime.parse(_futureExpiration).toLocal();

      expect(auth.accessTokenExpiration, expected);
    });

    test('uses empty string defaults when optional fields are null', () {
      final auth = AuthModel.fromJson({
        'accessTokenExpiration': _futureExpiration,
      });

      expect(auth.userId, '');
      expect(auth.fullName, '');
      expect(auth.phoneNumber, '');
      expect(auth.roles, isEmpty);
      expect(auth.accessToken, '');
      expect(auth.refreshToken, '');
    });

    test('parses multiple roles', () {
      final auth = AuthModel.fromJson({
        ..._validJson(),
        'roles': ['Admin', 'Manager'],
      });

      expect(auth.roles, ['Admin', 'Manager']);
    });

    test('uses empty list when roles is null', () {
      final auth = AuthModel.fromJson({
        ..._validJson(),
        'roles': null,
      });

      expect(auth.roles, isEmpty);
    });

    test('uses empty list when roles is not a list', () {
      final auth = AuthModel.fromJson({
        ..._validJson(),
        'roles': 'Admin',
      });

      expect(auth.roles, isEmpty);
    });

    test('throws when accessTokenExpiration is missing', () {
      expect(
        () => AuthModel.fromJson({'userId': 'u1'}),
        throwsA(anything),
      );
    });

    test('throws when accessTokenExpiration is not a valid date string', () {
      expect(
        () => AuthModel.fromJson({
          ..._validJson(),
          'accessTokenExpiration': 'not-a-date',
        }),
        throwsA(anything),
      );
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  group('Auth entity getters', () {
    test('primaryRole returns the first role', () {
      final auth = AuthModel.fromJson(_validJson());
      expect(auth.primaryRole, 'Manager');
    });

    test('primaryRole returns empty string when roles list is empty', () {
      final auth = AuthModel.fromJson({
        ..._validJson(),
        'roles': <dynamic>[],
      });
      expect(auth.primaryRole, '');
    });

    test('primaryRole returns first when multiple roles present', () {
      final auth = AuthModel.fromJson({
        ..._validJson(),
        'roles': ['Admin', 'Manager'],
      });
      expect(auth.primaryRole, 'Admin');
    });
  });
}
