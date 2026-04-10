import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/domain/repositories/group_repository.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/create_group_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeGroupRepository implements GroupRepository {
  Group? _response;
  Object? _error;

  String? capturedName;
  String? capturedColor;
  String? capturedDescription;

  void succeedWith(Group group) => _response = group;
  void failWith(Object error) => _error = error;

  @override
  Future<Group> create({
    required String name,
    String? color,
    String? description,
  }) async {
    capturedName = name;
    capturedColor = color;
    capturedDescription = description;
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<List<Group>> getAll() => throw UnimplementedError();

  @override
  Future<Group> update(String id, {required String name, String? color, String? description}) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Group _fakeGroup() => Group(
      id: 'new-id',
      name: 'Team Alpha',
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeGroupRepository repository;
  late CreateGroupUseCase usecase;

  setUp(() {
    repository = _FakeGroupRepository();
    usecase = CreateGroupUseCase(repository);
  });

  group('CreateGroupUseCase', () {
    test('passes name, color, and description directly to repository', () async {
      repository.succeedWith(_fakeGroup());

      await usecase(name: 'Team Alpha', color: '#FF0000', description: 'Red team');

      expect(repository.capturedName, 'Team Alpha');
      expect(repository.capturedColor, '#FF0000');
      expect(repository.capturedDescription, 'Red team');
    });

    test('returns the Group object that the repository provides', () async {
      final expected = _fakeGroup();
      repository.succeedWith(expected);

      final result = await usecase(name: 'Team Alpha');

      expect(result.id, expected.id);
      expect(result.name, expected.name);
    });

    test('passes null color and description when not supplied', () async {
      repository.succeedWith(_fakeGroup());

      await usecase(name: 'Minimal');

      expect(repository.capturedColor, isNull);
      expect(repository.capturedDescription, isNull);
    });

    test('propagates exception from repository without modification', () {
      repository.failWith('Name already exists');

      expect(
        () => usecase(name: 'Duplicate'),
        throwsA(equals('Name already exists')),
      );
    });
  });
}
