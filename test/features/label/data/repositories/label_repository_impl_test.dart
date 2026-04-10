import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tracking_mobile/features/label/data/label_remote_datasource.dart';
import 'package:task_tracking_mobile/features/label/data/label_repository_impl.dart';
import 'package:task_tracking_mobile/features/label/data/models/label_model.dart';

class MockLabelRemoteDatasource extends Mock implements LabelRemoteDatasource {}

// ── Helpers ───────────────────────────────────────────────────────────────────

LabelModel _fakeLabel({String id = '1', String name = 'Bug'}) => LabelModel(
      id: id,
      name: name,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

DioException _serverError(int status) {
  final opts = RequestOptions(path: '/labels');
  return DioException(
    requestOptions: opts,
    response: Response(
      requestOptions: opts,
      statusCode: status,
      data: <String, dynamic>{},
    ),
    type: DioExceptionType.badResponse,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockLabelRemoteDatasource mockRemote;
  late LabelRepositoryImpl repository;

  setUp(() {
    mockRemote = MockLabelRemoteDatasource();
    repository = LabelRepositoryImpl(mockRemote);
  });

  // ── getAll ────────────────────────────────────────────────────────────────

  group('getAll', () {
    test('returns labels from remote datasource', () async {
      final expected = [_fakeLabel(), _fakeLabel(id: '2', name: 'Feature')];
      when(() => mockRemote.getAll()).thenAnswer((_) async => expected);

      final result = await repository.getAll();

      expect(result, expected);
      verify(() => mockRemote.getAll()).called(1);
    });

    test('returns empty list when remote returns empty', () async {
      when(() => mockRemote.getAll()).thenAnswer((_) async => []);

      final result = await repository.getAll();

      expect(result, isEmpty);
    });

    test('propagates DioException from remote without mapping', () {
      when(() => mockRemote.getAll()).thenThrow(_serverError(500));

      expect(
        () => repository.getAll(),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ── create ────────────────────────────────────────────────────────────────

  group('create', () {
    test('delegates to remote and returns the created label', () async {
      final created = _fakeLabel(id: 'new-id', name: 'Priority');
      when(() => mockRemote.create(name: any(named: 'name'), description: any(named: 'description')))
          .thenAnswer((_) async => created);

      final result = await repository.create(name: 'Priority');

      expect(result.id, 'new-id');
      expect(result.name, 'Priority');
      verify(() => mockRemote.create(name: 'Priority', description: null)).called(1);
    });

    test('passes description to remote when provided', () async {
      final created = _fakeLabel(id: '1', name: 'Bug');
      when(() => mockRemote.create(
            name: any(named: 'name'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => created);

      await repository.create(name: 'Bug', description: 'A defect');

      verify(() => mockRemote.create(name: 'Bug', description: 'A defect'))
          .called(1);
    });

    test('propagates DioException from remote', () {
      when(() => mockRemote.create(
            name: any(named: 'name'),
            description: any(named: 'description'),
          )).thenThrow(_serverError(400));

      expect(
        () => repository.create(name: 'Bad'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ── update ────────────────────────────────────────────────────────────────

  group('update', () {
    test('delegates to remote with id and returns updated label', () async {
      final updated = _fakeLabel(id: '1', name: 'Updated Bug');
      when(() => mockRemote.update(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => updated);

      final result = await repository.update('1', name: 'Updated Bug');

      expect(result.name, 'Updated Bug');
      verify(() => mockRemote.update('1', name: 'Updated Bug', description: null))
          .called(1);
    });

    test('propagates DioException from remote', () {
      when(() => mockRemote.update(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
          )).thenThrow(_serverError(404));

      expect(
        () => repository.update('999', name: 'Ghost'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ── delete ────────────────────────────────────────────────────────────────

  group('delete', () {
    test('delegates to remote with the correct id', () async {
      when(() => mockRemote.delete('1')).thenAnswer((_) async {});

      await repository.delete('1');

      verify(() => mockRemote.delete('1')).called(1);
    });

    test('propagates DioException from remote', () {
      when(() => mockRemote.delete(any())).thenThrow(_serverError(403));

      expect(
        () => repository.delete('1'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
