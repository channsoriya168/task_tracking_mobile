import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_card.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/profile/profile_info_row.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.isDark,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.placeOfBirth,
    required this.dateOfBirth,
  });

  final bool isDark;
  final String fullName;
  final String email;
  final String phone;
  final String placeOfBirth;
  final DateTime? dateOfBirth;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.person_rounded, 'Full Name', fullName.isEmpty ? '—' : fullName),
      (Icons.email_rounded, 'Email', email.isEmpty ? '—' : email),
      (Icons.phone_rounded, 'Phone', phone.isEmpty ? '—' : phone),
      (Icons.location_on_rounded, 'Place of Birth', placeOfBirth.isEmpty ? '—' : placeOfBirth),
      (
        Icons.cake_rounded,
        'Date of Birth',
        dateOfBirth != null
            ? '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year}'
            : '—',
      ),
    ];

    final iconColor = isDark ? Colors.white54 : Colors.black45;

    return ProfileCard(
      isDark: isDark,
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, label, value) = items[i];
          return ProfileInfoRow(
            isDark: isDark,
            icon: icon,
            iconColor: iconColor,
            label: label,
            value: value,
            showDivider: i < items.length - 1,
          );
        }),
      ),
    );
  }
}
