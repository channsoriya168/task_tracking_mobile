import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_info_row.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.isDark,
    required this.email,
    required this.phone,
    required this.placeOfBirth,
    required this.dateOfBirth,
  });

  final bool isDark;
  final String email;
  final String phone;
  final String placeOfBirth;
  final DateTime? dateOfBirth;

  @override
  Widget build(BuildContext context) {
    final dateStr = dateOfBirth != null
        ? '${dateOfBirth!.day.toString().padLeft(2, '0')}/'
              '${dateOfBirth!.month.toString().padLeft(2, '0')}/'
              '${dateOfBirth!.year}'
        : null;

    final items = [
      if (email.isNotEmpty) (Icons.alternate_email_rounded, kPrimary, email),
      (Icons.phone_rounded, kPrimary, phone.isEmpty ? '—' : phone),
      (
        Icons.location_on_rounded,
        kPrimary,
        placeOfBirth.isEmpty ? '—' : placeOfBirth,
      ),
      if (dateStr != null) (Icons.cake_rounded, kPrimary, dateStr),
    ];

    return Container(
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, color, value) = items[i];
          return ProfileInfoRow(
            isDark: isDark,
            icon: icon,
            iconColor: color,
            value: value,
            showDivider: i < items.length - 1,
          );
        }),
      ),
    );
  }
}
