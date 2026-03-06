import 'package:flutter/material.dart';

enum EmployeeMenuAction {
  viewDetail,
  edit,
  generateQr,
  resetQr,
  delete,
}

class EmployeeMenuItem {
  const EmployeeMenuItem({
    required this.action,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.isWarning = false,
    this.isDanger = false,
  });

  final EmployeeMenuAction action;
  final IconData icon;
  final String label;

  /// Semantic color flags — the widget resolves the actual Color.
  final bool isPrimary;
  final bool isWarning;
  final bool isDanger;
}