import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/create_label_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeLabelRepository implements LabelRepository {
  Label? _response;
  Object? _error;

  String? capturedName;
  String? capturedDescription;

  void succeedWith(Label label) => _response = label;
  void failWith(Object error) => _error = error;

  @override
  Future<Label> create({required String name, String? description}) async {
    capturedName = name;
    capturedDescription = description;
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<List<Label>> getAll() => throw UnimplementedError();

  @override
  Future<Label> update(String id, {required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Label _fakeLabel() => Label(
      id: 'new-id',
      name: 'Priority',
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeLabelRepository repository;
  late CreateLabelUseCase usecase;

  setUp(() {
    repository = _FakeLabelRepository();
    usecase = CreateLabelUseCase(repository);
  });

  group('CreateLabelUseCase', () {
    test('passes name and description directly to repository', () async {
      repository.succeedWith(_fakeLabel());

      await usecase(name: 'Priority', description: 'High importance items');

      expect(repository.capturedName, 'Priority');
      expect(repository.capturedDescription, 'High importance items');
    });

    test('returns the Label object that the repository provides', () async {
      final expected = _fakeLabel();
      repository.succeedWith(expected);

      final result = await usecase(name: 'Priority');

      expect(result.id, expected.id);
      expect(result.name, expected.name);
    });

    test('passes null description when not supplied', () async {
      repository.succeedWith(_fakeLabel());

      await usecase(name: 'Minimal');

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
