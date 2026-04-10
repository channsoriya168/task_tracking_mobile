import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_tracking_mobile/features/group/data/datasources/group_remote_datasource.dart';
import 'package:task_tracking_mobile/features/group/data/models/group_model.dart';
import 'package:task_tracking_mobile/features/group/data/repositories/group_repository_impl.dart';

class MockGroupRemoteDatasource extends Mock implements GroupRemoteDatasource {}

void main() {
  late MockGroupRemoteDatasource mockRemoteDatasource;
  late GroupRepositoryImpl groupRepository;

  setUp(() {
    mockRemoteDatasource = MockGroupRemoteDatasource();
    groupRepository = GroupRepositoryImpl(mockRemoteDatasource);
  });

  group('getAll', () {
    test('returns groups from remote datasource', () async {
      final expected = [
        GroupModel(
          id: '1',
          name: 'Work',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        ),
      ];

      when(
        () => mockRemoteDatasource.getAll(),
      ).thenAnswer((_) async => expected);

      final result = await groupRepository.getAll();

      expect(result, expected);
      verify(() => mockRemoteDatasource.getAll()).called(1);
    });

    test('maps dio timeout into friendly message', () async {
      final timeoutError = DioException(
        requestOptions: RequestOptions(path: '/groups'),
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockRemoteDatasource.getAll()).thenThrow(timeoutError);

      expect(
        () => groupRepository.getAll(),
        throwsA('Connection timed out. Please try again.'),
      );
    });
  });
}
