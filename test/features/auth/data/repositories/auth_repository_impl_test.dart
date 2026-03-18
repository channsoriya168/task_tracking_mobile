import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/app/services/storage_service.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/employee_profile.dart';

// ── Fake datasource ──────────────────────────────────────────────────────────

class _FakeRemoteDatasource extends AuthRemoteDatasource {
  Auth? loginResult;
  Object? loginError;
  String? capturedLoginPhone;

  Auth? refreshResult;
  Object? refreshError;

  EmployeeProfile? profileResult;
  Object? profileError;

  Object? changePasswordError;
  String? capturedChangePasswordCurrent;

  Object? updateProfileError;

  _FakeRemoteDatasource() : super.withDio(Dio());

  @override
  Future<Auth> login(String phoneNumber, String password) async {
    capturedLoginPhone = phoneNumber;
    if (loginError != null) throw loginError!;
    return loginResult!;
  }

  @override
  Future<Auth> refreshToken(String accessToken, String refreshToken) async {
    if (refreshError != null) throw refreshError!;
    return refreshResult!;
  }

  @override
  Future<EmployeeProfile?> fetchProfile() async {
    if (profileError != null) throw profileError!;
    return profileResult;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    capturedChangePasswordCurrent = currentPassword;
    if (changePasswordError != null) throw changePasswordError!;
  }

  @override
  Future<void> updateProfile({File? image, bool removeImage = false}) async {
    if (updateProfileError != null) throw updateProfileError!;
  }
}

// ── Fake storage ─────────────────────────────────────────────────────────────

class _FakeStorageService extends StorageService {
  String? _token;
  String? _refreshToken;
  DateTime? _expiration;
  List<String> _roles = [];
  bool clearAllCalled = false;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveRefreshToken(String token) async => _refreshToken = token;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokenExpiration(DateTime expiration) async =>
      _expiration = expiration;

  @override
  Future<DateTime?> readTokenExpiration() async => _expiration;

  @override
  Future<void> saveRoles(List<String> roles) async => _roles = List.of(roles);

  @override
  Future<List<String>> readRoles() async => List.of(_roles);

  @override
  Future<void> clearAll() async {
    clearAllCalled = true;
    _token = null;
    _refreshToken = null;
    _expiration = null;
    _roles = [];
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _futureExpiration = DateTime.now().add(const Duration(days: 365));
final _pastExpiration = DateTime.now().subtract(const Duration(hours: 1));

Auth _makeAuth({String role = 'Manager'}) => Auth(
      userId: 'u1',
      fullName: 'Alice',
      phoneNumber: '+85512345678',
      roles: [role],
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      accessTokenExpiration: _futureExpiration,
    );

DioException _makeDioError(int statusCode, {String? message}) => DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: statusCode,
        data: message != null ? {'message': message} : null,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl – login()', () {
    test('normalizes phone number to E.164 format', () async {
      final remote = _FakeRemoteDatasource()..loginResult = _makeAuth();
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      await repo.login('0884311016', 'password');

      expect(remote.capturedLoginPhone, '+855884311016');
    });

    test('returns Auth on success', () async {
      final auth = _makeAuth();
      final remote = _FakeRemoteDatasource()..loginResult = auth;
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      final result = await repo.login('+85512345678', 'password');

      expect(result.userId, auth.userId);
      expect(result.roles, auth.roles);
    });

    test('saves session to storage on success', () async {
      final auth = _makeAuth();
      final remote = _FakeRemoteDatasource()..loginResult = auth;
      final storage = _FakeStorageService();
      final repo = AuthRepositoryImpl(remote, storage);

      await repo.login('+85512345678', 'password');

      expect(await storage.readToken(), auth.accessToken);
      expect(await storage.readRefreshToken(), auth.refreshToken);
      expect(await storage.readRoles(), auth.roles);
    });

    test('maps 401 DioException to human-readable message', () async {
      final remote = _FakeRemoteDatasource()
        ..loginError = _makeDioError(401, message: 'Incorrect credentials');
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      expect(
        () => repo.login('+85512345678', 'wrong'),
        throwsA('Incorrect credentials'),
      );
    });

    test('maps 400 DioException to message from response', () async {
      final remote = _FakeRemoteDatasource()
        ..loginError = _makeDioError(400, message: 'Bad request');
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      expect(
        () => repo.login('+85512345678', 'password'),
        throwsA('Bad request'),
      );
    });

    test('maps connection timeout to user-friendly message', () async {
      final remote = _FakeRemoteDatasource()
        ..loginError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      expect(
        () => repo.login('+85512345678', 'password'),
        throwsA(contains('timed out')),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl – logout()', () {
    test('clears all stored data', () async {
      final storage = _FakeStorageService();
      final repo = AuthRepositoryImpl(_FakeRemoteDatasource(), storage);

      await repo.logout();

      expect(storage.clearAllCalled, isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl – checkAuth()', () {
    test('throws when no token expiration in storage', () async {
      final storage = _FakeStorageService(); // all null by default
      final repo = AuthRepositoryImpl(_FakeRemoteDatasource(), storage);

      await expectLater(
        () => repo.checkAuth(),
        throwsA(isA<Exception>()),
      );
    });

    test('returns Auth from storage when token is still valid', () async {
      final storage = _FakeStorageService();
      await storage.saveToken('stored_token');
      await storage.saveRefreshToken('stored_refresh');
      await storage.saveTokenExpiration(_futureExpiration);
      await storage.saveRoles(['Manager']);

      final repo = AuthRepositoryImpl(_FakeRemoteDatasource(), storage);
      final auth = await repo.checkAuth();

      expect(auth.accessToken, 'stored_token');
      expect(auth.refreshToken, 'stored_refresh');
      expect(auth.roles, ['Manager']);
      expect(auth.accessTokenExpiration, _futureExpiration);
    });

    test('calls refreshToken when token is expired', () async {
      final refreshedAuth = _makeAuth();
      final remote = _FakeRemoteDatasource()
        ..refreshResult = refreshedAuth;

      final storage = _FakeStorageService();
      await storage.saveToken('old_token');
      await storage.saveRefreshToken('old_refresh');
      await storage.saveTokenExpiration(_pastExpiration); // expired

      final repo = AuthRepositoryImpl(remote, storage);
      final auth = await repo.checkAuth();

      expect(auth.accessToken, refreshedAuth.accessToken);
    });

    test('throws when token and refreshToken are missing from storage', () async {
      final storage = _FakeStorageService();
      await storage.saveTokenExpiration(_futureExpiration); // expiration set but no tokens

      final repo = AuthRepositoryImpl(_FakeRemoteDatasource(), storage);

      await expectLater(
        () => repo.checkAuth(),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl – refreshToken()', () {
    test('throws when no tokens in storage', () async {
      final storage = _FakeStorageService(); // all null
      final repo = AuthRepositoryImpl(_FakeRemoteDatasource(), storage);

      await expectLater(
        () => repo.refreshToken(),
        throwsA(isA<Exception>()),
      );
    });

    test('returns refreshed Auth and saves new session', () async {
      final refreshed = _makeAuth();
      final remote = _FakeRemoteDatasource()..refreshResult = refreshed;

      final storage = _FakeStorageService();
      await storage.saveToken('old_token');
      await storage.saveRefreshToken('old_refresh');

      final repo = AuthRepositoryImpl(remote, storage);
      final result = await repo.refreshToken();

      expect(result.accessToken, refreshed.accessToken);
      expect(await storage.readToken(), refreshed.accessToken);
    });

    test('maps DioException on refresh failure', () async {
      final remote = _FakeRemoteDatasource()
        ..refreshError = _makeDioError(401, message: 'Token expired');

      final storage = _FakeStorageService();
      await storage.saveToken('token');
      await storage.saveRefreshToken('refresh');

      final repo = AuthRepositoryImpl(remote, storage);

      expect(
        () => repo.refreshToken(),
        throwsA('Token expired'),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl – fetchProfile()', () {
    test('returns profile from datasource', () async {
      final profile = EmployeeProfile(
        userId: 'u1',
        fullName: 'Alice',
        phoneNumber: '+85512345678',
        roles: ['Manager'],
        employeeId: 'e1',
        email: 'alice@example.com',
        isActive: true,
        taskGroups: [],
      );
      final remote = _FakeRemoteDatasource()..profileResult = profile;
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      final result = await repo.fetchProfile();

      expect(result?.userId, 'u1');
    });

    test('returns null when datasource returns null', () async {
      final remote = _FakeRemoteDatasource()..profileResult = null;
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      final result = await repo.fetchProfile();

      expect(result, isNull);
    });

    test('maps DioException on fetch failure', () async {
      final remote = _FakeRemoteDatasource()
        ..profileError = _makeDioError(500);
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      expect(
        () => repo.fetchProfile(),
        throwsA(contains('Server error')),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl – changePassword()', () {
    test('delegates to datasource', () async {
      final remote = _FakeRemoteDatasource();
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      await repo.changePassword(
        currentPassword: 'old',
        newPassword: 'New@1234',
        confirmNewPassword: 'New@1234',
      );

      expect(remote.capturedChangePasswordCurrent, 'old');
    });

    test('throws string message for 400 (wrong current password)', () async {
      final remote = _FakeRemoteDatasource()
        ..changePasswordError = _makeDioError(400);
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      expect(
        () => repo.changePassword(
          currentPassword: 'wrong',
          newPassword: 'New@1234',
          confirmNewPassword: 'New@1234',
        ),
        throwsA('Current password is incorrect.'),
      );
    });

    test('maps non-400 DioException to error message', () async {
      final remote = _FakeRemoteDatasource()
        ..changePasswordError = _makeDioError(500);
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      expect(
        () => repo.changePassword(
          currentPassword: 'pass',
          newPassword: 'New@1234',
          confirmNewPassword: 'New@1234',
        ),
        throwsA(contains('Server error')),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AuthRepositoryImpl – updateProfile()', () {
    test('completes without error on success', () async {
      final repo = AuthRepositoryImpl(_FakeRemoteDatasource(), _FakeStorageService());

      await expectLater(
        repo.updateProfile(removeImage: true),
        completes,
      );
    });

    test('maps DioException on update failure', () async {
      final remote = _FakeRemoteDatasource()
        ..updateProfileError = _makeDioError(403);
      final repo = AuthRepositoryImpl(remote, _FakeStorageService());

      expect(
        () => repo.updateProfile(),
        throwsA('Access denied.'),
      );
    });
  });
}
