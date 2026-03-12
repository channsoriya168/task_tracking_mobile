import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_shared_widgets.dart';

class ProfileInfoCardWidget extends StatelessWidget {
  const ProfileInfoCardWidget({
    super.key,
    required this.isDark,
    required this.phone,
    required this.placeOfBirth,
    required this.dateOfBirth,
  });

  final bool isDark;
  final String phone;
  final String placeOfBirth;
  final DateTime? dateOfBirth;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.phone_rounded,
        'Phone',
        phone.isEmpty ? '—' : phone,
        const Color(0xFF2ED573),
      ),
      (
        Icons.location_on_rounded,
        'Place of Birth',
        placeOfBirth.isEmpty ? '—' : placeOfBirth,
        const Color(0xFFFFA502),
      ),
      (
        Icons.calendar_today_rounded,
        'Date of Birth',
        dateOfBirth != null
            ? '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}'
            : '—',
        const Color(0xFF6C63FF),
      ),
    ];

    return ProfileCard(
      isDark: isDark,
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, label, value, color) = items[i];
          return ProfileInfoRow(
            isDark: isDark,
            icon: icon,
            iconColor: color,
            label: label,
            value: value,
            showDivider: i < items.length - 1,
          );
        }),
      ),
    );
  }
}