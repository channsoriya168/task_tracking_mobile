import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/profile/presentation/widgets/profile_card.dart';
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
    final items = [
      if (email.isNotEmpty) (Icons.email_rounded, 'profile_email'.tr, email),
      (Icons.phone_rounded, 'profile_phone'.tr, phone.isEmpty ? '—' : phone),
      (
        Icons.location_on_rounded,
        'profile_place_of_birth'.tr,
        placeOfBirth.isEmpty ? '—' : placeOfBirth,
      ),
      if (dateOfBirth != null)
        (
          Icons.cake_rounded,
          'profile_date_of_birth'.tr,
          dateOfBirth != null
              ? '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year}'
              : '—',
        ),
    ];

    return ProfileCard(
      isDark: isDark,
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, label, value) = items[i];
          return ProfileInfoRow(
            isDark: isDark,
            icon: icon,
            iconColor: kPrimary,
            label: label,
            value: value,
            showDivider: i < items.length - 1,
          );
        }),
      ),
    );
  }
}
