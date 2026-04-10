import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/domain/repositories/group_repository.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/update_group_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeGroupRepository implements GroupRepository {
  Group? _response;
  Object? _error;

  String? capturedId;
  String? capturedName;
  String? capturedColor;
  String? capturedDescription;

  void succeedWith(Group group) => _response = group;
  void failWith(Object error) => _error = error;

  @override
  Future<Group> update(
    String id, {
    required String name,
    String? color,
    String? description,
  }) async {
    capturedId = id;
    capturedName = name;
    capturedColor = color;
    capturedDescription = description;
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<List<Group>> getAll() => throw UnimplementedError();

  @override
  Future<Group> create({required String name, String? color, String? description}) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Group _fakeGroup({String id = 'grp-1', String name = 'Updated'}) => Group(
      id: id,
      name: name,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeGroupRepository repository;
  late UpdateGroupUseCase usecase;

  setUp(() {
    repository = _FakeGroupRepository();
    usecase = UpdateGroupUseCase(repository);
  });

  group('UpdateGroupUseCase', () {
    test('passes id, name, color, and description directly to repository',
        () async {
      repository.succeedWith(_fakeGroup());

      await usecase(
        'grp-1',
        name: 'Renamed',
        color: '#00FF00',
        description: 'Green team',
      );

      expect(repository.capturedId, 'grp-1');
      expect(repository.capturedName, 'Renamed');
      expect(repository.capturedColor, '#00FF00');
      expect(repository.capturedDescription, 'Green team');
    });

    test('returns the updated Group from the repository', () async {
      final expected = _fakeGroup(id: 'grp-1', name: 'Renamed');
      repository.succeedWith(expected);

      final result = await usecase('grp-1', name: 'Renamed');

      expect(result.id, 'grp-1');
      expect(result.name, 'Renamed');
    });

    test('passes null color and description when not supplied', () async {
      repository.succeedWith(_fakeGroup());

      await usecase('grp-1', name: 'No extras');

      expect(repository.capturedColor, isNull);
      expect(repository.capturedDescription, isNull);
    });

    test('propagates exception from repository without modification', () {
      repository.failWith('Task group not found.');

      expect(
        () => usecase('999', name: 'Ghost'),
        throwsA(equals('Task group not found.')),
      );
    });
  });
}
