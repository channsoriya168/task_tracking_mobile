import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/core/data/models/employee_model.dart';

void main() {
  Map<String, dynamic> _validJson() => {
        'id': 'emp1',
        'fullName': 'John Doe',
        'email': 'john@example.com',
        'phone': '+85512345678',
        'isActive': true,
        'role': 'Employee',
        'profileImageUrl': 'https://example.com/photo.jpg',
        'placeOfBirth': 'Phnom Penh',
        'dateOfBirth': '1990-01-15',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-06-01T00:00:00.000Z',
        'taskGroups': [
          <String, dynamic>{
            'groupId': 'g1',
            'groupName': 'Dev Team',
            'groupColor': '#3B82F6',
            'role': 1,
            'joinedAt': '2024-01-10T00:00:00.000Z',
          },
        ],
      };

  // ──────────────────────────────────────────────────────────────────────────
  group('EmployeeModel.fromJson()', () {
    test('maps all top-level fields from valid JSON', () {
      final model = EmployeeModel.fromJson(_validJson());
      expect(model.id, 'emp1');
      expect(model.fullName, 'John Doe');
      expect(model.email, 'john@example.com');
      expect(model.phone, '+85512345678');
      expect(model.isActive, isTrue);
      expect(model.role, 'Employee');
      expect(model.profileImageUrl, 'https://example.com/photo.jpg');
      expect(model.placeOfBirth, 'Phnom Penh');
    });

    test('parses dateOfBirth correctly', () {
      final model = EmployeeModel.fromJson(_validJson());
      expect(model.dateOfBirth?.year, 1990);
      expect(model.dateOfBirth?.month, 1);
      expect(model.dateOfBirth?.day, 15);
    });

    test('parses createdAt and updatedAt', () {
      final model = EmployeeModel.fromJson(_validJson());
      expect(model.createdAt.year, 2024);
      expect(model.updatedAt, isNotNull);
    });

    test('defaults email to empty string when absent', () {
      final json = _validJson()..remove('email');
      expect(EmployeeModel.fromJson(json).email, '');
    });

    test('defaults isActive to true when absent', () {
      final json = _validJson()..remove('isActive');
      expect(EmployeeModel.fromJson(json).isActive, isTrue);
    });

    test('handles null dateOfBirth', () {
      final json = _validJson()..['dateOfBirth'] = null;
      expect(EmployeeModel.fromJson(json).dateOfBirth, isNull);
    });

    test('handles null updatedAt', () {
      final json = _validJson()..['updatedAt'] = null;
      expect(EmployeeModel.fromJson(json).updatedAt, isNull);
    });

    test('handles null phone', () {
      final json = _validJson()..['phone'] = null;
      expect(EmployeeModel.fromJson(json).phone, isNull);
    });

    test('handles null profileImageUrl', () {
      final json = _validJson()..['profileImageUrl'] = null;
      expect(EmployeeModel.fromJson(json).profileImageUrl, isNull);
    });

    test('defaults taskGroups to empty list when null', () {
      final json = _validJson()..['taskGroups'] = null;
      expect(EmployeeModel.fromJson(json).taskGroups, isEmpty);
    });

    test('defaults taskGroups to empty list when key is absent', () {
      final json = _validJson()..remove('taskGroups');
      expect(EmployeeModel.fromJson(json).taskGroups, isEmpty);
    });

    test('skips task group entries with null groupId', () {
      final json = _validJson();
      (json['taskGroups'] as List).add({'groupId': null, 'groupName': 'Skip'});
      expect(EmployeeModel.fromJson(json).taskGroups, hasLength(1));
    });

    // ── Task group fields ────────────────────────────────────────────────────

    test('parses task group fields correctly', () {
      final group = EmployeeModel.fromJson(_validJson()).taskGroups.first;
      expect(group.groupId, 'g1');
      expect(group.groupName, 'Dev Team');
      expect(group.role, 1);
    });

    test('defaults groupName to empty string when null', () {
      final json = _validJson();
      (json['taskGroups'] as List).first['groupName'] = null;
      expect(EmployeeModel.fromJson(json).taskGroups.first.groupName, '');
    });

    test('converts hex color string to Color object', () {
      final group = EmployeeModel.fromJson(_validJson()).taskGroups.first;
      expect(group.groupColor, const Color(0xFF3B82F6));
    });

    test('defaults groupColor to #3B82F6 when null', () {
      final json = _validJson();
      (json['taskGroups'] as List).first['groupColor'] = null;
      final group = EmployeeModel.fromJson(json).taskGroups.first;
      expect(group.groupColor, const Color(0xFF3B82F6));
    });

    test('extracts integer role directly from task group', () {
      final json = _validJson();
      (json['taskGroups'] as List).first['role'] = 0;
      expect(EmployeeModel.fromJson(json).taskGroups.first.role, 0);
    });

    test('extracts role id from Map in task group', () {
      final json = _validJson();
      (json['taskGroups'] as List).first['role'] = {'id': 1, 'name': 'Lead'};
      expect(EmployeeModel.fromJson(json).taskGroups.first.role, 1);
    });

    test('defaults task group role to 0 for unrecognized type', () {
      final json = _validJson();
      (json['taskGroups'] as List).first['role'] = 'lead_string';
      expect(EmployeeModel.fromJson(json).taskGroups.first.role, 0);
    });

    test('uses current time for joinedAt when null', () {
      final before = DateTime.now();
      final json = _validJson();
      (json['taskGroups'] as List).first['joinedAt'] = null;
      final joinedAt = EmployeeModel.fromJson(json).taskGroups.first.joinedAt;
      final after = DateTime.now();
      expect(joinedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(joinedAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('handles minimal JSON with only required fields', () {
      final json = <String, dynamic>{
        'id': 'emp2',
        'fullName': 'Jane',
        'createdAt': '2024-03-01T00:00:00.000Z',
      };
      final model = EmployeeModel.fromJson(json);
      expect(model.id, 'emp2');
      expect(model.fullName, 'Jane');
      expect(model.email, '');
      expect(model.phone, isNull);
      expect(model.role, isNull);
      expect(model.profileImageUrl, isNull);
      expect(model.placeOfBirth, isNull);
      expect(model.dateOfBirth, isNull);
      expect(model.taskGroups, isEmpty);
    });

    test('handles multiple task groups', () {
      final json = _validJson();
      (json['taskGroups'] as List).add({
        'groupId': 'g2',
        'groupName': 'QA Team',
        'groupColor': '#EF4444',
        'role': 0,
        'joinedAt': '2024-02-01T00:00:00.000Z',
      });
      expect(EmployeeModel.fromJson(json).taskGroups, hasLength(2));
    });
  });
}
