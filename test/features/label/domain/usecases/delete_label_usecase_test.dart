import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/delete_label_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeLabelRepository implements LabelRepository {
  Object? _error;
  String? capturedId;
  bool deleteCalled = false;

  void failWith(Object error) => _error = error;

  @override
  Future<void> delete(String id) async {
    capturedId = id;
    deleteCalled = true;
    if (_error != null) throw _error!;
  }

  @override
  Future<List<Label>> getAll() => throw UnimplementedError();

  @override
  Future<Label> create({required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<Label> update(String id, {required String name, String? description}) =>
      throw UnimplementedError();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeLabelRepository repository;
  late DeleteLabelUseCase usecase;

  setUp(() {
    repository = _FakeLabelRepository();
    usecase = DeleteLabelUseCase(repository);
  });

  group('DeleteLabelUseCase', () {
    test('calls repository.delete with the correct id', () async {
      await usecase('lbl-42');

      expect(repository.capturedId, 'lbl-42');
      expect(repository.deleteCalled, isTrue);
    });

    test('completes without error on success', () async {
      await expectLater(usecase('lbl-1'), completes);
    });

    test('propagates exception from repository without modification', () {
      repository.failWith('Label not found.');

      expect(
        () => usecase('999'),
        throwsA(equals('Label not found.')),
      );
    });

    test('propagates access denied error', () {
      repository.failWith('Access denied.');

      expect(
        () => usecase('lbl-restricted'),
        throwsA(equals('Access denied.')),
      );
    });
  });
}
