import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/domain/repositories/group_repository.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/get_all_groups_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeGroupRepository implements GroupRepository {
  List<Group>? _response;
  Object? _error;

  void succeedWith(List<Group> groups) => _response = groups;
  void failWith(Object error) => _error = error;

  @override
  Future<List<Group>> getAll() async {
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<Group> create({required String name, String? color, String? description}) =>
      throw UnimplementedError();

  @override
  Future<Group> update(String id, {required String name, String? color, String? description}) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Group _fakeGroup({String id = '1', String name = 'Work'}) => Group(
      id: id,
      name: name,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeGroupRepository repository;
  late GetAllGroupsUseCase usecase;

  setUp(() {
    repository = _FakeGroupRepository();
    usecase = GetAllGroupsUseCase(repository);
  });

  group('GetAllGroupsUseCase', () {
    test('returns the list of groups from the repository', () async {
      final expected = [_fakeGroup(), _fakeGroup(id: '2', name: 'Design')];
      repository.succeedWith(expected);

      final result = await usecase();

      expect(result, expected);
      expect(result.length, 2);
    });

    test('returns an empty list when the repository has no groups', () async {
      repository.succeedWith([]);

      final result = await usecase();

      expect(result, isEmpty);
    });

    test('propagates exception from repository without modification', () {
      repository.failWith('Task group not found.');

      expect(
        () => usecase(),
        throwsA(equals('Task group not found.')),
      );
    });
  });
}
