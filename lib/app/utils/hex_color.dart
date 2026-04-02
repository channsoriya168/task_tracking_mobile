import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

Color hexColor(String hex) {
  final clean = hex.replaceFirst('#', '');
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return kPrimary;
  return Color(0xFF000000 | value);
}
