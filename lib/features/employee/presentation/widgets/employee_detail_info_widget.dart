import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';

class EmployeeDetailInfoListWidget extends StatelessWidget {
  const EmployeeDetailInfoListWidget({
    super.key,
    required this.employee,
    required this.isDark,
  });

  final Employee employee;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF3F4F6);

    String? genderName;
    if (employee.genderId != null) {
      final empCtrl = Get.find<EmployeeController>();
      final match = empCtrl.genders
          .where((g) => g.id == employee.genderId)
          .toList();
      if (match.isNotEmpty) genderName = match.first.name;
    }

    final rows = <_InfoRowData>[
      _InfoRowData(
        icon: Icons.email_outlined,
        label: 'Email',
        value: employee.email,
      ),
      if (employee.phone != null)
        _InfoRowData(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: employee.phone!,
        ),
      if (genderName != null)
        _InfoRowData(
          icon: Icons.wc_outlined,
          label: 'emp_form_gender_label'.tr,
          value: genderName,
        ),
      if (employee.dateOfBirth != null)
        _InfoRowData(
          icon: Icons.cake_outlined,
          label: 'Date of Birth',
          value: formatDate(employee.dateOfBirth!),
        ),
      if (employee.placeOfBirth != null)
        _InfoRowData(
          icon: Icons.location_on_outlined,
          label: 'Place of Birth',
          value: employee.placeOfBirth!,
        ),
      _InfoRowData(
        icon: Icons.calendar_today_outlined,
        label: 'Joined',
        value: formatDate(employee.createdAt),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Information',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(rows.length, (i) {
          return Column(
            children: [
              _InfoListRow(
                data: rows[i],
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              if (i < rows.length - 1) Divider(height: 1, color: dividerColor),
            ],
          );
        }),
      ],
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoListRow extends StatelessWidget {
  const _InfoListRow({
    required this.data,
    required this.textColor,
    required this.mutedColor,
  });

  final _InfoRowData data;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(data.icon, size: 20, color: mutedColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
