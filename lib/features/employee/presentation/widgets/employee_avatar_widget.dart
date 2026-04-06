import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/user_avatar_widget.dart';

class EmployeeAvatarWidget extends StatelessWidget {
  const EmployeeAvatarWidget({
    super.key,
    required this.name,
    required this.color,
    required this.radius,
    this.imagePath,
  });

  final String name;
  final Color color;
  final double radius;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return UserAvatarWidget(
      name: name,
      imageUrl: imagePath,
      radius: radius,
      color: color,
    );
  }
}

String employeeInitials(String name) => UserAvatarWidget.initials(name);