import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts [Color?] ↔ hex [String?] (e.g. "#3B82F6").
class ColorConverter implements JsonConverter<Color?, String?> {
  const ColorConverter();

  @override
  Color? fromJson(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final sanitized = hex.replaceAll('#', '');
    final value = int.tryParse(
      sanitized.length == 6 ? 'FF$sanitized' : sanitized,
      radix: 16,
    );
    return value != null ? Color(value) : null;
  }

  @override
  String? toJson(Color? color) {
    if (color == null) return null;
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}

/// Use with `@JsonKey(fromJson: nullableDateTimeFromJson)` for `DateTime?`
/// fields where the API may omit the key or send null.
DateTime? nullableDateTimeFromJson(String? value) =>
    value != null ? DateTime.tryParse(value) : null;

String? nullableDateTimeToJson(DateTime? value) => value?.toIso8601String();