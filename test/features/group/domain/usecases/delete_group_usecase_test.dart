import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/domain/repositories/group_repository.dart';
import 'package:task_tracking_mobile/features/group/domain/usecases/delete_group_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeGroupRepository implements GroupRepository {
  Object? _error;
  String? capturedId;
  bool deleteCalled = false;

  void succeedOnDelete() {}
  void failWith(Object error) => _error = error;

  @override
  Future<void> delete(String id) async {
    capturedId = id;
    deleteCalled = true;
    if (_error != null) throw _error!;
  }

  @override
  Future<List<Group>> getAll() => throw UnimplementedError();

  @override
  Future<Group> create({required String name, String? color, String? description}) =>
      throw UnimplementedError();

  @override
  Future<Group> update(String id, {required String name, String? color, String? description}) =>
      throw UnimplementedError();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeGroupRepository repository;
  late DeleteGroupUseCase usecase;

  setUp(() {
    repository = _FakeGroupRepository();
    usecase = DeleteGroupUseCase(repository);
  });

  group('DeleteGroupUseCase', () {
    test('calls repository.delete with the correct id', () async {
      await usecase('grp-42');

      expect(repository.capturedId, 'grp-42');
      expect(repository.deleteCalled, isTrue);
    });

    test('completes without error on success', () async {
      await expectLater(usecase('grp-1'), completes);
    });

    test('propagates exception from repository without modification', () {
      repository.failWith('Task group not found.');

      expect(
        () => usecase('999'),
        throwsA(equals('Task group not found.')),
      );
    });

    test('propagates access denied error', () {
      repository.failWith('Access denied.');

      expect(
        () => usecase('grp-restricted'),
        throwsA(equals('Access denied.')),
      );
    });
  });
}
