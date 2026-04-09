import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/core/network/local/storage_service.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_tracking_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_tracking_mobile/features/auth/domain/entities/auth.dart';

// ── Stubs ─────────────────────────────────────────────────────────────────────
//
// These replace real dependencies. The datasource stub returns a pre-set Auth
// (or throws) — it simulates what AuthRemoteDatasource would return after
// talking to the server. The storage stub is an in-memory map.

class _FakeRemote extends AuthRemoteDatasource {
  _FakeRemote() : super.withDio(Dio());

  Auth? _response;
  DioException? _error;

  String? capturedPhone;

  void succeedWith(Auth auth) => _response = auth;
  void failWith(DioException error) => _error = error;

  @override
  Future<Auth> login(String phoneNumber, String password) async {
    capturedPhone = phoneNumber;
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<Auth> refreshToken(String accessToken, String refreshToken) async {
    if (_error != null) throw _error!;
    return _response!;
  }
}

class _FakeStorage extends StorageService {
  String? token;
  String? refreshToken;
  DateTime? expiration;
  List<String> roles = [];

  @override
  Future<void> saveToken(String t) async => token = t;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> saveRefreshToken(String t) async => refreshToken = t;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokenExpiration(DateTime e) async => expiration = e;

  @override
  Future<DateTime?> readTokenExpiration() async => expiration;

  @override
  Future<void> saveRoles(List<String> r) async => roles = r;

  @override
  Future<List<String>> readRoles() async => roles;

  @override
  Future<void> clearAll() async {
    token = null;
    refreshToken = null;
    expiration = null;
    roles = [];
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// This is the Auth that the (fake) remote datasource returns —
// it represents what the server would have sent back as JSON, already parsed.
Auth _serverAuth() => Auth(
      userId: 'abc-123',
      fullName: 'Chea Sophannarith',
      phoneNumber: '+855884311016',
      roles: ['employee'],
      accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      refreshToken: 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4',
      accessTokenExpiration: DateTime(2030),
    );

DioException _httpError(int status, {String? message}) {
  final opts = RequestOptions(path: '/login');
  return DioException(
    requestOptions: opts,
    response: Response(
      requestOptions: opts,
      statusCode: status,
      data: message != null ? {'message': message} : <String, dynamic>{},
    ),
    type: DioExceptionType.badResponse,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeRemote remote;
  late _FakeStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemote();
    storage = _FakeStorage();
    repository = AuthRepositoryImpl(remote, storage);
  });

  // ── Phone number conversion ───────────────────────────────────────────────

  group('phone number E.164 conversion', () {
    test('converts 0-prefixed local number to E.164 before sending to API',
        () async {
      remote.succeedWith(_serverAuth());

      await repository.login('0884311016', 'password123');

      // Repository must NOT send the raw "0884311016" to the server —
      // it must be converted to "+855884311016" first.
      expect(remote.capturedPhone, '+855884311016');
    });

    test('passes already-E.164 number through without double-converting',
        () async {
      remote.succeedWith(_serverAuth());

      await repository.login('+855884311016', 'password123');

      expect(remote.capturedPhone, '+855884311016');
    });
  });

  // ── Session persistence ───────────────────────────────────────────────────

  group('session persistence on successful login', () {
    test('saves access token to storage', () async {
      remote.succeedWith(_serverAuth());
      await repository.login('0884311016', 'password123');

      expect(storage.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
    });

    test('saves refresh token to storage', () async {
      remote.succeedWith(_serverAuth());
      await repository.login('0884311016', 'password123');

      expect(storage.refreshToken, 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4');
    });

    test('saves user roles to storage', () async {
      remote.succeedWith(_serverAuth());
      await repository.login('0884311016', 'password123');

      expect(storage.roles, ['employee']);
    });

    test('saves token expiration to storage', () async {
      remote.succeedWith(_serverAuth());
      await repository.login('0884311016', 'password123');

      expect(storage.expiration, DateTime(2030));
    });

    test('returns the Auth that came from the server', () async {
      remote.succeedWith(_serverAuth());

      final result = await repository.login('0884311016', 'password123');

      expect(result.userId, 'abc-123');
      expect(result.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
    });
  });

  // ── Error mapping ─────────────────────────────────────────────────────────

  group('error mapping', () {
    test('maps 401 to "Incorrect phone number or password."', () async {
      remote.failWith(_httpError(401));

      expect(
        () => repository.login('0884311016', 'wrong'),
        throwsA(equals('Incorrect phone number or password.')),
      );
    });

    test('maps 400 with server message to that message', () async {
      remote.failWith(_httpError(400, message: 'Account has been disabled'));

      expect(
        () => repository.login('0884311016', 'pass'),
        throwsA(equals('Account has been disabled')),
      );
    });

    test('maps connection error to readable message', () async {
      remote.failWith(DioException(
        requestOptions: RequestOptions(path: '/login'),
        type: DioExceptionType.connectionError,
      ));

      expect(
        () => repository.login('0884311016', 'pass'),
        throwsA(equals('Unable to reach the server. Check your connection.')),
      );
    });

    test('does NOT save session when login fails', () async {
      remote.failWith(_httpError(401));

      try {
        await repository.login('0884311016', 'wrong');
      } catch (_) {}

      expect(storage.token, isNull);
    });
  });

  // ── Logout ────────────────────────────────────────────────────────────────

  group('logout', () {
    test('clears all session data from storage', () async {
      remote.succeedWith(_serverAuth());
      await repository.login('0884311016', 'password123');

      await repository.logout();

      expect(storage.token, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.roles, isEmpty);
    });
  });
}
