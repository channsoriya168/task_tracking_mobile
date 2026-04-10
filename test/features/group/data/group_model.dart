import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_mobile/features/group/data/models/group_model.dart';

void main() {
  test("Group fromJson should parse correctly ", () {
    final json = {
      "id": "123",
      "name": "Test Group",
      "color": "#0000FF", // Blue color in hex format expected by API
      "description": "A test group",
      "isActive": true,
      "createdAt": "2024-01-01T12:00:00Z",
      "updatedAt": "2024-01-02T12:00:00Z",
    };
    final group = GroupModel.fromJson(json);
    expect(group.id, "123");
    expect(group.name, "Test Group");
    expect(group.color?.value, 0xFF0000FF);
    expect(group.description, "A test group");
    expect(group.isActive, true);
    expect(group.createdAt, DateTime.parse("2024-01-01T12:00:00Z"));
    expect(group.updatedAt, DateTime.parse("2024-01-02T12:00:00Z"));
  });
  test("Group tojson should parse correctly", () {
    final group = GroupModel(
      id: "123",
      name: "Test Group",
      color: const Color(0xFF0000FF), // Blue color
      description: "A test group",
      isActive: true,
      createdAt: DateTime.parse("2024-01-01T12:00:00Z"),
      updatedAt: DateTime.parse("2024-01-02T12:00:00Z"),
    );
    final json = group.toJson();
    expect(json['id'], "123");
    expect(json['name'], "Test Group");
    expect(json['color'], "#0000FF");
    expect(json['description'], "A test group");
    expect(json['isActive'], true);
    expect(json['createdAt'], "2024-01-01T12:00:00.000Z");
    expect(json['updatedAt'], "2024-01-02T12:00:00.000Z");
  });
}
