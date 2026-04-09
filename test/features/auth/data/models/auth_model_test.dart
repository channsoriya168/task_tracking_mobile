import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/auth/data/models/auth_model.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';

// Real API-shaped JSON — mirrors exactly what the server returns.
const _apiResponse = {
  'userId': 'abc-123',
  'fullName': 'Chea Sophannarith',
  'phoneNumber': '+855884311016',
  'roles': ['employee'],
  'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
  'refreshToken': 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4',
  'accessTokenExpiration': '2030-06-01T00:00:00.000Z',
};

void main() {
  group('AuthModel.fromJson', () {
    test('parses all fields from real API response', () {
      final auth = AuthModel.fromJson(_apiResponse);

      expect(auth.userId, 'abc-123');
      expect(auth.fullName, 'Chea Sophannarith');
      expect(auth.phoneNumber, '+855884311016');
      expect(auth.roles, ['employee']);
      expect(auth.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
      expect(auth.refreshToken, 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4');
    });

    test('parses accessTokenExpiration as DateTime', () {
      final auth = AuthModel.fromJson(_apiResponse);

      expect(auth.accessTokenExpiration, isA<DateTime>());
      // toLocal() shifts the UTC time — just verify it's past now
      expect(auth.accessTokenExpiration.isAfter(DateTime.now()), isTrue);
    });

    test('returns Auth entity (not a model subclass)', () {
      final result = AuthModel.fromJson(_apiResponse);
      expect(result, isA<Auth>());
    });

    test('handles multiple roles', () {
      final json = Map<String, dynamic>.from(_apiResponse)
        ..['roles'] = ['admin', 'manager', 'employee'];

      final auth = AuthModel.fromJson(json);

      expect(auth.roles, ['admin', 'manager', 'employee']);
      expect(auth.primaryRole, 'admin');
    });

    test('handles null roles as empty list', () {
      final json = Map<String, dynamic>.from(_apiResponse)
        ..['roles'] = null;

      final auth = AuthModel.fromJson(json);

      expect(auth.roles, isEmpty);
      expect(auth.primaryRole, '');
    });

    test('handles missing optional fields with safe defaults', () {
      final minimal = {
        'accessToken': 'some-token',
        'refreshToken': 'some-refresh',
        'accessTokenExpiration': '2030-01-01T00:00:00.000Z',
      };

      final auth = AuthModel.fromJson(minimal);

      expect(auth.userId, '');
      expect(auth.fullName, '');
      expect(auth.phoneNumber, '');
    });
  });
}
