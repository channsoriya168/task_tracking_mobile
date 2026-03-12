import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

// ── Hero header ──────────────────────────────────────────────────

class EmployeeDetailHeader extends StatelessWidget {
  const EmployeeDetailHeader({
    super.key,
    required this.employee,
    required this.isDark,
  });

  final Employee employee;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accent = employee.taskGroups.isNotEmpty
        ? employee.taskGroups.first.groupColor
        : kPrimary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: isDark ? 0.55 : 0.90),
            accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -28,
            right: -28,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              children: [
                // avatar + active badge
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                      child: EmployeeAvatar(
                        name: employee.fullName,
                        color: Colors.white,
                        radius: 40,
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
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // name
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
                // email
                Text(
                  employee.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                // active status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: employee.isActive
                        ? const Color(0xFF2ED573).withValues(alpha: 0.20)
                        : const Color(0xFFFF4757).withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: employee.isActive
                          ? const Color(0xFF2ED573).withValues(alpha: 0.50)
                          : const Color(0xFFFF4757).withValues(alpha: 0.50),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: employee.isActive
                              ? const Color(0xFF2ED573)
                              : const Color(0xFFFF4757),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        employee.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: employee.isActive
                              ? const Color(0xFF2ED573)
                              : const Color(0xFFFF4757),
                        ),
                      ),
                    ],
                  ),
                ),
                // task group badges
                if (employee.taskGroups.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: employee.taskGroups.map((g) {
                      final isLead = g.role == 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
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
                            if (isLead) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Lead',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
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
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────

class EmployeeDetailInfoCard extends StatelessWidget {
  const EmployeeDetailInfoCard({
    super.key,
    required this.employee,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });

  final Employee employee;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRowData>[
      if (employee.phone != null)
        _InfoRowData(icon: Icons.phone_outlined, label: 'Phone', value: employee.phone!),
      if (employee.dateOfBirth != null)
        _InfoRowData(icon: Icons.cake_outlined, label: 'Date of Birth', value: _formatDate(employee.dateOfBirth!)),
      if (employee.placeOfBirth != null)
        _InfoRowData(icon: Icons.location_on_outlined, label: 'Place of Birth', value: employee.placeOfBirth!),
      _InfoRowData(icon: Icons.calendar_today_outlined, label: 'Joined', value: _formatDate(employee.createdAt)),
    ];

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      isDark: isDark,
      borderColor: borderColor,
      cardBg: cardBg,
      icon: Icons.person_outline_rounded,
      label: 'Profile Info',
      child: Column(
        children: List.generate(rows.length, (i) {
          return _InfoRow(
            data: rows[i],
            isDark: isDark,
            borderColor: borderColor,
            showDivider: i < rows.length - 1,
          );
        }),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.data,
    required this.isDark,
    required this.borderColor,
    required this.showDivider,
  });

  final _InfoRowData data;
  final bool isDark;
  final Color borderColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                data.icon,
                size: 20,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : kTextMuted,
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
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
    required this.icon,
    required this.label,
    required this.child,
    this.trailing,
  });

  final bool isDark;
  final Color borderColor;
  final Color cardBg;
  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 4),
          Divider(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            height: 20,
          ),
          child,
        ],
      ),
    );
  }
}
