import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee/employee_avatar_widget.dart';

// ── Header (FlexibleSpaceBar background) ─────────────────────────

class EmployeeDetailHeaderContent extends StatelessWidget {
  const EmployeeDetailHeaderContent({
    super.key,
    required this.employee,
    required this.accent,
  });

  final Employee employee;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.85), accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 48, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar with status dot
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                          child: EmployeeAvatarWidget(
                            name: employee.fullName,
                            color: Colors.white,
                            radius: 44,
                            imagePath: employee.profileImageUrl,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: employee.isActive
                                  ? const Color(0xFF2ED573)
                                  : const Color(0xFFFF4757),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      employee.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                    if (employee.taskGroups.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: employee.taskGroups.map((g) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  g.groupName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (g.role == 1) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Lead',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ────────────────────────────────────────────────────

class EmployeeDetailStats extends StatelessWidget {
  const EmployeeDetailStats({
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
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(
              label: 'Groups',
              value: '${employee.taskGroups.length}',
              valueColor: textColor,
              labelColor: mutedColor,
            ),
            VerticalDivider(width: 1, color: dividerColor),
            _StatItem(
              label: 'Status',
              value: employee.isActive ? 'Active' : 'Inactive',
              valueColor: employee.isActive
                  ? const Color(0xFF2ED573)
                  : const Color(0xFFFF4757),
              labelColor: mutedColor,
            ),
            VerticalDivider(width: 1, color: dividerColor),
            _StatItem(
              label: 'Since',
              value: '${employee.createdAt.year}',
              valueColor: textColor,
              labelColor: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        ],
      ),
    );
  }
}

// ── Action buttons ────────────────────────────────────────────────

class EmployeeDetailActions extends StatelessWidget {
  const EmployeeDetailActions({
    super.key,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Edit Employee',
            icon: Icons.edit_rounded,
            color: kPrimary,
            filled: true,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            color: kHighPriority,
            filled: false,
            onTap: onDelete,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: filled ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info list (no card) ───────────────────────────────────────────

class EmployeeDetailInfoList extends StatelessWidget {
  const EmployeeDetailInfoList({
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

    final rows = <_InfoData>[
      _InfoData(
        icon: Icons.email_outlined,
        label: 'Email',
        value: employee.email,
      ),
      if (employee.phone != null)
        _InfoData(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: employee.phone!.startsWith('+855')
              ? '0${employee.phone!.substring(4)}'
              : employee.phone!,
        ),
      if (employee.dateOfBirth != null)
        _InfoData(
          icon: Icons.cake_outlined,
          label: 'Date of Birth',
          value: formatDate(employee.dateOfBirth!),
        ),
      if (employee.placeOfBirth != null)
        _InfoData(
          icon: Icons.location_on_outlined,
          label: 'Place of Birth',
          value: employee.placeOfBirth!,
        ),
      _InfoData(
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
              _InfoRow(
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

class _InfoData {
  final IconData icon;
  final String label;
  final String value;
  const _InfoData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.data,
    required this.textColor,
    required this.mutedColor,
  });

  final _InfoData data;
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
