import 'package:flutter/material.dart';

class TaskDetailAvatar extends StatelessWidget {
  const TaskDetailAvatar({
    super.key,
    required this.name,
    required this.color,
    required this.size,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, _) {},
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
