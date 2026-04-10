import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tracking_mobile/features/group/data/datasources/group_remote_datasource.dart';
import 'package:task_tracking_mobile/features/group/data/models/group_model.dart';
import 'package:task_tracking_mobile/features/group/data/repositories/group_repository_impl.dart';

class MockGroupRemoteDatasource extends Mock implements GroupRemoteDatasource {}

// ── Helpers ───────────────────────────────────────────────────────────────────

GroupModel _fakeGroup({String id = '1', String name = 'Work'}) => GroupModel(
      id: id,
      name: name,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

DioException _timeoutError() => DioException(
      requestOptions: RequestOptions(path: '/groups'),
      type: DioExceptionType.connectionTimeout,
    );

DioException _connectionError() => DioException(
      requestOptions: RequestOptions(path: '/groups'),
      type: DioExceptionType.connectionError,
    );

DioException _httpError(int status, {String? message}) {
  final opts = RequestOptions(path: '/groups');
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
  late MockGroupRemoteDatasource mockRemote;
  late GroupRepositoryImpl repository;

  setUpAll(() {
    // mocktail requires a registered fallback for any custom type used with any()
    registerFallbackValue(
      GroupModel(id: '', name: '', createdAt: DateTime(2024)),
    );
  });

  setUp(() {
    mockRemote = MockGroupRemoteDatasource();
    repository = GroupRepositoryImpl(mockRemote);
  });

  // ── getAll ────────────────────────────────────────────────────────────────

  group('getAll', () {
    test('returns groups from remote datasource', () async {
      final expected = [_fakeGroup(), _fakeGroup(id: '2', name: 'Design')];
      when(() => mockRemote.getAll()).thenAnswer((_) async => expected);

      final result = await repository.getAll();

      expect(result, expected);
      verify(() => mockRemote.getAll()).called(1);
    });

    test('maps connection timeout to friendly message', () {
      when(() => mockRemote.getAll()).thenThrow(_timeoutError());

      expect(
        () => repository.getAll(),
        throwsA('Connection timed out. Please try again.'),
      );
    });

    test('maps receive timeout to friendly message', () {
      when(() => mockRemote.getAll()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/groups'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(
        () => repository.getAll(),
        throwsA('Connection timed out. Please try again.'),
      );
    });

    test('maps connection error to friendly message', () {
      when(() => mockRemote.getAll()).thenThrow(_connectionError());

      expect(
        () => repository.getAll(),
        throwsA('Unable to reach the server. Check your connection.'),
      );
    });

    test('maps 401 to "Unauthorized."', () {
      when(() => mockRemote.getAll()).thenThrow(_httpError(401));

      expect(
        () => repository.getAll(),
        throwsA('Unauthorized.'),
      );
    });

    test('maps 403 to "Access denied."', () {
      when(() => mockRemote.getAll()).thenThrow(_httpError(403));

      expect(
        () => repository.getAll(),
        throwsA('Access denied.'),
      );
    });

    test('maps 404 to "Task group not found."', () {
      when(() => mockRemote.getAll()).thenThrow(_httpError(404));

      expect(
        () => repository.getAll(),
        throwsA('Task group not found.'),
      );
    });

    test('maps 500 to server error message', () {
      when(() => mockRemote.getAll()).thenThrow(_httpError(500));

      expect(
        () => repository.getAll(),
        throwsA('Server error. Please try again later.'),
      );
    });

    test('maps 400 with server message to that message', () {
      when(() => mockRemote.getAll())
          .thenThrow(_httpError(400, message: 'Invalid filter parameter'));

      expect(
        () => repository.getAll(),
        throwsA('Invalid filter parameter'),
      );
    });
  });

  // ── create ────────────────────────────────────────────────────────────────

  group('create', () {
    test('calls remote.create and returns the created group', () async {
      final created = _fakeGroup(id: 'new-id', name: 'Team Alpha');
      when(() => mockRemote.create(any())).thenAnswer((_) async => created);

      final result = await repository.create(name: 'Team Alpha');

      expect(result.id, 'new-id');
      expect(result.name, 'Team Alpha');
      verify(() => mockRemote.create(any())).called(1);
    });

    test('passes color and description through to the model', () async {
      GroupModel? capturedModel;
      when(() => mockRemote.create(any())).thenAnswer((invocation) async {
        capturedModel = invocation.positionalArguments[0] as GroupModel;
        return capturedModel!;
      });

      await repository.create(
        name: 'Blue Team',
        color: '#0000FF',
        description: 'The blue squad',
      );

      expect(capturedModel?.name, 'Blue Team');
      expect(capturedModel?.description, 'The blue squad');
      expect(capturedModel?.color?.value, 0xFF0000FF);
    });

    test('maps DioException from create to friendly message', () {
      when(() => mockRemote.create(any()))
          .thenThrow(_httpError(400, message: 'Name already exists'));

      expect(
        () => repository.create(name: 'Duplicate'),
        throwsA('Name already exists'),
      );
    });

    test('maps 500 from create to server error message', () {
      when(() => mockRemote.create(any())).thenThrow(_httpError(500));

      expect(
        () => repository.create(name: 'Test'),
        throwsA('Server error. Please try again later.'),
      );
    });
  });

  // ── update ────────────────────────────────────────────────────────────────

  group('update', () {
    test('calls remote.update with the correct id and returns updated group',
        () async {
      final updated = _fakeGroup(id: '1', name: 'Updated Name');
      when(() => mockRemote.update(any(), any()))
          .thenAnswer((_) async => updated);

      final result = await repository.update('1', name: 'Updated Name');

      expect(result.name, 'Updated Name');
      verify(() => mockRemote.update('1', any())).called(1);
    });

    test('maps 404 from update to "Task group not found."', () {
      when(() => mockRemote.update(any(), any())).thenThrow(_httpError(404));

      expect(
        () => repository.update('999', name: 'Ghost'),
        throwsA('Task group not found.'),
      );
    });

    test('maps connection timeout from update', () {
      when(() => mockRemote.update(any(), any())).thenThrow(_timeoutError());

      expect(
        () => repository.update('1', name: 'Slow'),
        throwsA('Connection timed out. Please try again.'),
      );
    });
  });

  // ── delete ────────────────────────────────────────────────────────────────

  group('delete', () {
    test('calls remote.delete with the correct id', () async {
      when(() => mockRemote.delete(any())).thenAnswer((_) async {});

      await repository.delete('1');

      verify(() => mockRemote.delete('1')).called(1);
    });

    test('maps 403 from delete to "Access denied."', () {
      when(() => mockRemote.delete(any())).thenThrow(_httpError(403));

      expect(
        () => repository.delete('1'),
        throwsA('Access denied.'),
      );
    });

    test('maps connection error from delete', () {
      when(() => mockRemote.delete(any())).thenThrow(_connectionError());

      expect(
        () => repository.delete('1'),
        throwsA('Unable to reach the server. Check your connection.'),
      );
    });
  });
}
