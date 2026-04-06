import 'package:flutter/material.dart';

abstract class LookupItem {
  final int id;
  final String name;

  const LookupItem({required this.id, required this.name});

  Color get color;
}