import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

// ── Avatar ─────────────────────────────────────────────────────
/// Circular avatar that shows [imagePath] when available,
/// falling back to the employee's initials.
class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar({
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

// ── Search Bar ─────────────────────────────────────────────────
/// Shared employee search bar used on both mobile and tablet layouts.
class EmployeeSearchBar extends StatelessWidget {
  const EmployeeSearchBar({
    super.key,
    required this.isDark,
    required this.ctrl,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 8),
  });

  final bool isDark;
  final EmployeeController ctrl;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        onChanged: (v) => ctrl.searchQuery.value = v,
        style: TextStyle(color: isDark ? Colors.white : kTextDark),
        decoration: InputDecoration(
          hintText: 'Search employees...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : kTextMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.grey[600] : kTextMuted,
            size: 20,
          ),
          filled: true,
          fillColor: isDark ? kCardDark : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ── Card Content Row ───────────────────────────────────────────
/// Shared inner row layout for employee cards (avatar + info + trailing icon).
/// Used in both the mobile list card and the tablet grid card.
class EmployeeCardContent extends StatelessWidget {
  const EmployeeCardContent({
    super.key,
    required this.employee,
    required this.accentColor,
    required this.isDark,
    required this.avatarRadius,
    required this.nameFontSize,
    required this.emailFontSize,
    required this.trailingIcon,
    this.position,
    this.clampText = false,
  });

  final Employee employee;
  final Color accentColor;
  final bool isDark;
  final double avatarRadius;
  final double nameFontSize;
  final double emailFontSize;
  final IconData trailingIcon;

  /// When set, shows a colored position badge below the email.
  final Position? position;

  /// When true, text is limited to 1 line with ellipsis (tablet grid).
  final bool clampText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EmployeeAvatar(
          name: employee.name,
          color: accentColor,
          radius: avatarRadius,
          imagePath: employee.imagePath,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                employee.name,
                maxLines: clampText ? 1 : null,
                overflow: clampText ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                employee.email,
                maxLines: clampText ? 1 : null,
                overflow: clampText ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontSize: emailFontSize,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ),
              if (position != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    position!.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Icon(
          trailingIcon,
          size: 16,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────
String employeeInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
