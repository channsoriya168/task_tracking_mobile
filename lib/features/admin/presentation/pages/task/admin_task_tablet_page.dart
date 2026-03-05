import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class AdminTaskTabletPage extends StatelessWidget {
  const AdminTaskTabletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? kBgDark : kBgLight,
      child: const Center(child: Text('Admin Tasks — Tablet')),
    );
  }
}
