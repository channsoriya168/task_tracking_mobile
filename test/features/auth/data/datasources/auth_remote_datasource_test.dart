import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

// ── Mock HTTP adapter ─────────────────────────────────────────────────────────
//
// Simulates the HTTP layer: when the datasource fires a POST request,
// this adapter intercepts it and returns a pre-configured status + body,
// just like the real server would — but without any network connection.

class _MockHttpAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> responseBody;

  _MockHttpAdapter({required this.statusCode, required this.responseBody});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(responseBody),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// The exact JSON shape the real server returns on successful login.
const _successResponseJson = {
  'userId': 'abc-123',
  'fullName': 'Chea Sophannarith',
  'phoneNumber': '+855884311016',
  'roles': ['employee'],
  'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
  'refreshToken': 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4',
  'accessTokenExpiration': '2030-06-01T00:00:00.000Z',
};

Dio _dioWith(_MockHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  dio.httpClientAdapter = adapter;
  // Disable default response JSON conversion so we control the raw map
  dio.options.responseType = ResponseType.json;
  return dio;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('AuthRemoteDatasource.login', () {
    test('returns Auth parsed from real server JSON on 200', () async {
      final dio = _dioWith(_MockHttpAdapter(
        statusCode: 200,
        responseBody: _successResponseJson,
      ));
      final datasource = AuthRemoteDatasource.withDio(dio);

      final auth = await datasource.login('+855884311016', 'password123');

      expect(auth.userId, 'abc-123');
      expect(auth.fullName, 'Chea Sophannarith');
      expect(auth.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
      expect(auth.refreshToken, 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4');
      expect(auth.roles, ['employee']);
    });

    test('throws DioException when server returns 401', () async {
      final dio = _dioWith(_MockHttpAdapter(
        statusCode: 401,
        responseBody: {'message': 'Incorrect phone number or password.'},
      ));
      final datasource = AuthRemoteDatasource.withDio(dio);

      expect(
        () => datasource.login('+855884311016', 'wrong-password'),
        throwsA(isA<DioException>()),
      );
    });

    test('throws DioException when accessToken in response is empty', () async {
      final emptyTokenResponse = Map<String, dynamic>.from(_successResponseJson)
        ..['accessToken'] = '';
      final dio = _dioWith(_MockHttpAdapter(
        statusCode: 200,
        responseBody: emptyTokenResponse,
      ));
      final datasource = AuthRemoteDatasource.withDio(dio);

      expect(
        () => datasource.login('+855884311016', 'password123'),
        throwsA(isA<DioException>()),
      );
    });

    test('throws DioException when server returns 500', () async {
      final dio = _dioWith(_MockHttpAdapter(
        statusCode: 500,
        responseBody: {'message': 'Internal server error'},
      ));
      final datasource = AuthRemoteDatasource.withDio(dio);

      expect(
        () => datasource.login('+855884311016', 'password123'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
