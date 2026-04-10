import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/update_label_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeLabelRepository implements LabelRepository {
  Label? _response;
  Object? _error;

  String? capturedId;
  String? capturedName;
  String? capturedDescription;

  void succeedWith(Label label) => _response = label;
  void failWith(Object error) => _error = error;

  @override
  Future<Label> update(
    String id, {
    required String name,
    String? description,
  }) async {
    capturedId = id;
    capturedName = name;
    capturedDescription = description;
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<List<Label>> getAll() => throw UnimplementedError();

  @override
  Future<Label> create({required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Label _fakeLabel({String id = 'lbl-1', String name = 'Updated'}) => Label(
      id: id,
      name: name,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeLabelRepository repository;
  late UpdateLabelUseCase usecase;

  setUp(() {
    repository = _FakeLabelRepository();
    usecase = UpdateLabelUseCase(repository);
  });

  group('UpdateLabelUseCase', () {
    test('passes id, name, and description directly to repository', () async {
      repository.succeedWith(_fakeLabel());

      await usecase('lbl-1', name: 'Renamed', description: 'New details');

      expect(repository.capturedId, 'lbl-1');
      expect(repository.capturedName, 'Renamed');
      expect(repository.capturedDescription, 'New details');
    });

    test('returns the updated Label from the repository', () async {
      final expected = _fakeLabel(id: 'lbl-1', name: 'Renamed');
      repository.succeedWith(expected);

      final result = await usecase('lbl-1', name: 'Renamed');

      expect(result.id, 'lbl-1');
      expect(result.name, 'Renamed');
    });

    test('passes null description when not supplied', () async {
      repository.succeedWith(_fakeLabel());

      await usecase('lbl-1', name: 'No extras');

      expect(repository.capturedDescription, isNull);
    });

    test('propagates exception from repository without modification', () {
      repository.failWith('Label not found.');

      expect(
        () => usecase('999', name: 'Ghost'),
        throwsA(equals('Label not found.')),
      );
    });
  });
}
