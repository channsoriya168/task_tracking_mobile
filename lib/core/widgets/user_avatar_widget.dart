import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

/// A reusable circular avatar that shows a [NetworkImage] when [imageUrl] is
/// provided, or falls back to 1- or 2-letter initials derived from [name].
///
/// Use [showBorder] to add a subtle colored ring (useful on cards).
class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
    required this.name,
    required this.radius,
    this.imageUrl,
    this.color,
    this.showBorder = false,
  });

  final String name;
  final double radius;
  final String? imageUrl;

  /// Tint color for background, initials text, and optional border.
  /// Defaults to [kPrimary].
  final Color? color;

  /// When true, wraps the avatar in a thin colored ring.
  final bool showBorder;

  /// Returns 1- or 2-letter initials from a full name.
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? kPrimary;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: c.withValues(alpha: 0.15),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: hasImage ? (_, _) {} : null,
      child: hasImage
          ? null
          : Text(
              initials(name),
              style: TextStyle(
                fontSize: radius * 0.65,
                fontWeight: FontWeight.w700,
                color: c,
              ),
            ),
    );

    if (!showBorder) return avatar;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: avatar,
    );
  }
}
