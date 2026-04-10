import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/label/domain/repositories/label_repository.dart';
import 'package:task_tracking_mobile/features/label/domain/usecases/get_all_labels_usecase.dart';

// ── Stub ─────────────────────────────────────────────────────────────────────

class _FakeLabelRepository implements LabelRepository {
  List<Label>? _response;
  Object? _error;

  void succeedWith(List<Label> labels) => _response = labels;
  void failWith(Object error) => _error = error;

  @override
  Future<List<Label>> getAll() async {
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Future<Label> create({required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<Label> update(String id, {required String name, String? description}) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Label _fakeLabel({String id = '1', String name = 'Bug'}) => Label(
      id: id,
      name: name,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeLabelRepository repository;
  late GetAllLabelsUseCase usecase;

  setUp(() {
    repository = _FakeLabelRepository();
    usecase = GetAllLabelsUseCase(repository);
  });

  group('GetAllLabelsUseCase', () {
    test('returns the list of labels from the repository', () async {
      final expected = [_fakeLabel(), _fakeLabel(id: '2', name: 'Feature')];
      repository.succeedWith(expected);

      final result = await usecase();

      expect(result, expected);
      expect(result.length, 2);
    });

    test('returns an empty list when the repository has no labels', () async {
      repository.succeedWith([]);

      final result = await usecase();

      expect(result, isEmpty);
    });

    test('propagates exception from repository without modification', () {
      repository.failWith('Unable to reach the server. Check your connection.');

      expect(
        () => usecase(),
        throwsA(equals('Unable to reach the server. Check your connection.')),
      );
    });
  });
}
