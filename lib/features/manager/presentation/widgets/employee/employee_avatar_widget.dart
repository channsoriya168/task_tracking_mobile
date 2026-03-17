import 'package:flutter/material.dart';

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
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withAlpha(40),
      backgroundImage: hasImage ? NetworkImage(imagePath!) : null,
      child: hasImage
          ? null
          : Text(
              employeeInitials(name),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.65,
              ),
            ),
    );
  }
}

String employeeInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
