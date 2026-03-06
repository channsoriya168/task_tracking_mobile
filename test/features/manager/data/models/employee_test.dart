import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';

void main() {
  group('Employee model', () {
    const employee = Employee(
      id: 'e1',
      name: 'Alice Johnson',
      email: 'alice@example.com',
      positionId: 'p1',
    );

    test('constructor sets all required fields', () {
      expect(employee.id, 'e1');
      expect(employee.name, 'Alice Johnson');
      expect(employee.email, 'alice@example.com');
      expect(employee.positionId, 'p1');
    });

    test('optional fields default to null', () {
      expect(employee.imagePath, isNull);
      expect(employee.dateOfBirth, isNull);
      expect(employee.placeOfBirth, isNull);
      expect(employee.phone, isNull);
      expect(employee.userId, isNull);
    });

    test('constructor sets optional fields when provided', () {
      final dob = DateTime(1990, 5, 20);
      final e = Employee(
        id: 'e2',
        name: 'Bob',
        email: 'bob@example.com',
        positionId: 'p2',
        imagePath: '/images/bob.jpg',
        dateOfBirth: dob,
        placeOfBirth: 'New York',
        phone: '555-1234',
        userId: 'u2',
      );

      expect(e.imagePath, '/images/bob.jpg');
      expect(e.dateOfBirth, dob);
      expect(e.placeOfBirth, 'New York');
      expect(e.phone, '555-1234');
      expect(e.userId, 'u2');
    });

    group('copyWith', () {
      test('returns same values when no arguments given', () {
        final copy = employee.copyWith();
        expect(copy.id, employee.id);
        expect(copy.name, employee.name);
        expect(copy.email, employee.email);
        expect(copy.positionId, employee.positionId);
      });

      test('overrides only the given fields', () {
        final copy = employee.copyWith(name: 'Bob', email: 'bob@example.com');
        expect(copy.name, 'Bob');
        expect(copy.email, 'bob@example.com');
        expect(copy.id, employee.id);
        expect(copy.positionId, employee.positionId);
      });

      test('can update positionId', () {
        final copy = employee.copyWith(positionId: 'p2');
        expect(copy.positionId, 'p2');
        expect(copy.id, employee.id);
      });

      test('can update optional fields', () {
        final dob = DateTime(1995, 3, 15);
        final copy = employee.copyWith(
          phone: '111-2222',
          dateOfBirth: dob,
          placeOfBirth: 'LA',
        );
        expect(copy.phone, '111-2222');
        expect(copy.dateOfBirth, dob);
        expect(copy.placeOfBirth, 'LA');
        expect(copy.name, employee.name);
      });
    });
  });

  group('kMockEmployees', () {
    test('is not empty', () {
      expect(kMockEmployees, isNotEmpty);
    });

    test('all employees have non-empty id, name, email, positionId', () {
      for (final e in kMockEmployees) {
        expect(e.id, isNotEmpty);
        expect(e.name, isNotEmpty);
        expect(e.email, isNotEmpty);
        expect(e.positionId, isNotEmpty);
      }
    });

    test('all ids are unique', () {
      final ids = kMockEmployees.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('Position model', () {
    const position = Position(
      id: 'p1',
      name: 'Engineering',
      color: Color(0xFF6C63FF),
    );

    test('constructor sets all fields', () {
      expect(position.id, 'p1');
      expect(position.name, 'Engineering');
      expect(position.color, const Color(0xFF6C63FF));
    });

    group('copyWith', () {
      test('returns same values when no arguments given', () {
        final copy = position.copyWith();
        expect(copy.id, position.id);
        expect(copy.name, position.name);
        expect(copy.color, position.color);
      });

      test('overrides only the given fields', () {
        const newColor = Color(0xFF2ED573);
        final copy = position.copyWith(name: 'Design', color: newColor);
        expect(copy.name, 'Design');
        expect(copy.color, newColor);
        expect(copy.id, position.id);
      });
    });
  });

  group('kMockPositions', () {
    test('contains at least one position', () {
      expect(kMockPositions, isNotEmpty);
    });

    test('all ids are unique', () {
      final ids = kMockPositions.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('all positions have non-empty fields', () {
      for (final p in kMockPositions) {
        expect(p.id, isNotEmpty);
        expect(p.name, isNotEmpty);
      }
    });
  });
}