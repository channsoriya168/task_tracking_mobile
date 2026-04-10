import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/label/data/models/label_model.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';

// Real API-shaped JSON — mirrors what the server returns.
const _apiResponse = {
  'id': 'lbl-001',
  'name': 'Bug',
  'color': '#E74C3C',
  'description': 'Something is broken',
  'isActive': true,
  'createdAt': '2024-03-10T09:00:00Z',
  'updatedAt': '2024-04-01T14:00:00Z',
};

void main() {
  // ── LabelModel.fromJson ───────────────────────────────────────────────────

  group('LabelModel.fromJson', () {
    test('parses all fields from real API response', () {
      final model = LabelModel.fromJson(_apiResponse);

      expect(model.id, 'lbl-001');
      expect(model.name, 'Bug');
      expect(model.color, '#E74C3C');
      expect(model.description, 'Something is broken');
      expect(model.isActive, true);
    });

    test('parses createdAt and updatedAt as DateTime', () {
      final model = LabelModel.fromJson(_apiResponse);

      expect(model.createdAt, DateTime.parse('2024-03-10T09:00:00Z'));
      expect(model.updatedAt, DateTime.parse('2024-04-01T14:00:00Z'));
    });

    test('color is stored as a plain String (not a Color object)', () {
      final model = LabelModel.fromJson(_apiResponse);

      expect(model.color, isA<String>());
      expect(model.color, '#E74C3C');
    });

    test('defaults isActive to true when absent', () {
      final json = Map<String, dynamic>.from(_apiResponse)
        ..remove('isActive');
      final model = LabelModel.fromJson(json);

      expect(model.isActive, true);
    });

    test('handles null color', () {
      final json = Map<String, dynamic>.from(_apiResponse)..['color'] = null;
      final model = LabelModel.fromJson(json);

      expect(model.color, isNull);
    });

    test('handles null updatedAt', () {
      final json = Map<String, dynamic>.from(_apiResponse)
        ..['updatedAt'] = null;
      final model = LabelModel.fromJson(json);

      expect(model.updatedAt, isNull);
    });

    test('handles null optional fields with safe defaults', () {
      final minimal = {
        'id': 'x',
        'name': 'Minimal',
        'createdAt': '2024-01-01T00:00:00Z',
      };
      final model = LabelModel.fromJson(minimal);

      expect(model.description, isNull);
      expect(model.color, isNull);
      expect(model.isActive, true);
    });

    test('returns a Label entity', () {
      final model = LabelModel.fromJson(_apiResponse);

      expect(model, isA<Label>());
    });
  });

  // ── LabelModel.toJson ─────────────────────────────────────────────────────

  group('LabelModel.toJson', () {
    final model = LabelModel(
      id: 'lbl-001',
      name: 'Bug',
      color: '#E74C3C',
      description: 'Something is broken',
      isActive: true,
      createdAt: DateTime.parse('2024-03-10T09:00:00.000Z'),
      updatedAt: DateTime.parse('2024-04-01T14:00:00.000Z'),
    );

    test('serializes all fields', () {
      final json = model.toJson();

      expect(json['id'], 'lbl-001');
      expect(json['name'], 'Bug');
      expect(json['color'], '#E74C3C');
      expect(json['description'], 'Something is broken');
      expect(json['isActive'], true);
    });

    test('serializes datetimes as ISO 8601 strings', () {
      final json = model.toJson();

      expect(json['createdAt'], '2024-03-10T09:00:00.000Z');
      expect(json['updatedAt'], '2024-04-01T14:00:00.000Z');
    });

    test('serializes null updatedAt as null', () {
      final noUpdate = LabelModel(
        id: '1',
        name: 'No update',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      expect(noUpdate.toJson()['updatedAt'], isNull);
    });
  });

  // ── LabelModel.toRequestJson ──────────────────────────────────────────────

  group('LabelModel.toRequestJson', () {
    test('includes name and description when both are set', () {
      final model = LabelModel(
        id: '1',
        name: 'Feature',
        description: 'New functionality',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final json = model.toRequestJson();

      expect(json['name'], 'Feature');
      expect(json['description'], 'New functionality');
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('isActive'), isFalse);
      expect(json.containsKey('color'), isFalse);
    });

    test('omits description when null', () {
      final model = LabelModel(
        id: '1',
        name: 'No desc',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final json = model.toRequestJson();

      expect(json.containsKey('description'), isFalse);
    });

    test('omits description when empty string', () {
      final model = LabelModel(
        id: '1',
        name: 'Empty desc',
        description: '',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final json = model.toRequestJson();

      expect(json.containsKey('description'), isFalse);
    });
  });
}
