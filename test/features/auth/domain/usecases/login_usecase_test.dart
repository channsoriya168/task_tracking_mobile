import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_tracking_mobile/features/auth/domain/usecases/login_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────
//
// Simulates the repository layer that LoginUsecase depends on.
// LoginUsecase itself has no business logic — it just calls repository.login().
// These tests verify that delegation happens correctly.

class _FakeAuthRepository implements AuthRepository {
  Auth? _response;
  Object? _error;

  String? capturedPhone;
  String? capturedPassword;

  void succeedWith(Auth auth) => _response = auth;
  void failWith(Object error) => _error = error;

  @override
  Future<Auth> login(String phoneNumber, String password) async {
    capturedPhone = phoneNumber;
    capturedPassword = password;
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Auth> refreshToken() async => _response!;

  @override
  Future<Auth> checkAuth() async => _response!;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Auth _fakeAuth() => Auth(
      userId: 'abc-123',
      fullName: 'Chea Sophannarith',
      phoneNumber: '+855884311016',
      roles: ['employee'],
      accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      refreshToken: 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4',
      accessTokenExpiration: DateTime(2030),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeAuthRepository repository;
  late LoginUsecase usecase;

  setUp(() {
    repository = _FakeAuthRepository();
    usecase = LoginUsecase(repository);
  });

  group('LoginUsecase', () {
    test('passes phone and password directly to repository', () async {
      repository.succeedWith(_fakeAuth());

      await usecase('0884311016', 'password123');

      // The usecase should forward the raw inputs to the repository.
      // Phone-to-E.164 conversion is the repository's job, not the usecase's.
      expect(repository.capturedPhone, '0884311016');
      expect(repository.capturedPassword, 'password123');
    });

    test('returns the Auth object that the repository provides', () async {
      final expected = _fakeAuth();
      repository.succeedWith(expected);

      final result = await usecase('0884311016', 'password123');

      expect(result.userId, expected.userId);
      expect(result.fullName, expected.fullName);
      expect(result.accessToken, expected.accessToken);
      expect(result.roles, expected.roles);
    });

    test('propagates exception from repository without modification', () async {
      repository.failWith('Incorrect phone number or password.');

      expect(
        () => usecase('0884311016', 'wrong-password'),
        throwsA(equals('Incorrect phone number or password.')),
      );
    });
  });
}
