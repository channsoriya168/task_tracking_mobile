import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/group/data/models/group_model.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';

// Real API-shaped JSON — mirrors what the server returns.
const _apiResponse = {
  'id': 'abc-123',
  'name': 'Design Team',
  'color': '#FF5733',
  'description': 'UI/UX designers',
  'isActive': true,
  'createdAt': '2024-01-01T08:00:00Z',
  'updatedAt': '2024-06-15T10:30:00Z',
};

void main() {
  // ── GroupModel.fromJson ───────────────────────────────────────────────────

  group('GroupModel.fromJson', () {
    test('parses all fields from real API response', () {
      final model = GroupModel.fromJson(_apiResponse);

      expect(model.id, 'abc-123');
      expect(model.name, 'Design Team');
      expect(model.description, 'UI/UX designers');
      expect(model.isActive, true);
    });

    test('parses hex color string into Color object', () {
      final model = GroupModel.fromJson(_apiResponse);

      // #FF5733 → 0xFFFF5733
      expect(model.color, isA<Color>());
      expect(model.color?.value, 0xFFFF5733);
    });

    test('parses createdAt and updatedAt as DateTime', () {
      final model = GroupModel.fromJson(_apiResponse);

      expect(model.createdAt, DateTime.parse('2024-01-01T08:00:00Z'));
      expect(model.updatedAt, DateTime.parse('2024-06-15T10:30:00Z'));
    });

    test('handles null color — color field stays null', () {
      final json = Map<String, dynamic>.from(_apiResponse)..['color'] = null;
      final model = GroupModel.fromJson(json);

      expect(model.color, isNull);
    });

    test('defaults isActive to true when absent', () {
      final json = Map<String, dynamic>.from(_apiResponse)
        ..remove('isActive');
      final model = GroupModel.fromJson(json);

      expect(model.isActive, true);
    });

    test('handles null updatedAt', () {
      final json = Map<String, dynamic>.from(_apiResponse)
        ..['updatedAt'] = null;
      final model = GroupModel.fromJson(json);

      expect(model.updatedAt, isNull);
    });

    test('handles null optional fields with safe defaults', () {
      final minimal = {
        'id': 'x',
        'name': 'Solo',
        'createdAt': '2024-01-01T00:00:00Z',
      };
      final model = GroupModel.fromJson(minimal);

      expect(model.description, isNull);
      expect(model.color, isNull);
      expect(model.isActive, true);
    });

    test('returns a Group entity', () {
      final model = GroupModel.fromJson(_apiResponse);

      expect(model, isA<Group>());
    });
  });

  // ── GroupModel.toJson ─────────────────────────────────────────────────────

  group('GroupModel.toJson', () {
    final model = GroupModel(
      id: 'abc-123',
      name: 'Design Team',
      color: const Color(0xFFFF5733),
      description: 'UI/UX designers',
      isActive: true,
      createdAt: DateTime.parse('2024-01-01T08:00:00.000Z'),
      updatedAt: DateTime.parse('2024-06-15T10:30:00.000Z'),
    );

    test('serializes all fields', () {
      final json = model.toJson();

      expect(json['id'], 'abc-123');
      expect(json['name'], 'Design Team');
      expect(json['description'], 'UI/UX designers');
      expect(json['isActive'], true);
    });

    test('serializes color as hex string', () {
      final json = model.toJson();

      expect(json['color'], '#FF5733');
    });

    test('serializes datetimes as ISO 8601 strings', () {
      final json = model.toJson();

      expect(json['createdAt'], '2024-01-01T08:00:00.000Z');
      expect(json['updatedAt'], '2024-06-15T10:30:00.000Z');
    });

    test('serializes null color as null', () {
      final noColor = GroupModel(
        id: '1',
        name: 'No color',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      expect(noColor.toJson()['color'], isNull);
    });

    test('serializes null updatedAt as null', () {
      final noUpdate = GroupModel(
        id: '1',
        name: 'No update',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      expect(noUpdate.toJson()['updatedAt'], isNull);
    });
  });

  // ── GroupModel.toRequestJson ──────────────────────────────────────────────

  group('GroupModel.toRequestJson', () {
    test('includes name, color, and description when all are set', () {
      final model = GroupModel(
        id: '1',
        name: 'Team Alpha',
        color: const Color(0xFF0000FF),
        description: 'Blue team',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final json = model.toRequestJson();

      expect(json['name'], 'Team Alpha');
      expect(json['color'], '#0000FF');
      expect(json['description'], 'Blue team');
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('isActive'), isFalse);
      expect(json.containsKey('createdAt'), isFalse);
    });

    test('omits color when null', () {
      final model = GroupModel(
        id: '1',
        name: 'No color',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final json = model.toRequestJson();

      expect(json.containsKey('color'), isFalse);
    });

    test('omits description when null', () {
      final model = GroupModel(
        id: '1',
        name: 'No desc',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );
      final json = model.toRequestJson();

      expect(json.containsKey('description'), isFalse);
    });
  });
}
