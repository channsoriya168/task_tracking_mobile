import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';
import 'package:task_tracking_mobile/features/employee/data/models/task_model.dart';

// ── Profile Header ─────────────────────────────────────────────
class EmployeeDetailHeader extends StatelessWidget {
  const EmployeeDetailHeader({
    super.key,
    required this.emp,
    required this.accentColor,
    required this.isDark,
    required this.taskGroup,
  });

  final Employee emp;
  final Color accentColor;
  final bool isDark;
  final TaskGroup? taskGroup;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 14),
          Text(
            emp.fullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          if (taskGroup != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                taskGroup!.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final url = emp.profileImageUrl;

    return CircleAvatar(
      radius: 48,
      backgroundColor: accentColor.withAlpha(40),
      backgroundImage: url != null && url.isNotEmpty
          ? NetworkImage(url) as ImageProvider
          : null,
      child: (url == null || url.isEmpty)
          ? Text(
              employeeInitials(emp.fullName),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            )
          : null,
    );
  }
}

// ── Personal Info Section ──────────────────────────────────────
class EmployeeInfoSection extends StatelessWidget {
  const EmployeeInfoSection({
    super.key,
    required this.emp,
    required this.isDark,
    required this.accentColor,
    required this.taskGroup,
  });

  final Employee emp;
  final bool isDark;
  final Color accentColor;
  final TaskGroup? taskGroup;

  @override
  Widget build(BuildContext context) {
    return EmployeeInfoCard(
      isDark: isDark,
      children: [
        EmployeeInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: emp.email,
          isDark: isDark,
        ),
        if (emp.phone != null && emp.phone!.isNotEmpty)
          EmployeeInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: emp.phone!,
            isDark: isDark,
          ),
        if (emp.dateOfBirth != null)
          EmployeeInfoRow(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: DateFormat('dd MMM yyyy').format(emp.dateOfBirth!),
            isDark: isDark,
          ),
        if (emp.placeOfBirth != null && emp.placeOfBirth!.isNotEmpty)
          EmployeeInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Place of Birth',
            value: emp.placeOfBirth!,
            isDark: isDark,
          ),
        if (taskGroup != null)
          EmployeeInfoRow(
            icon: Icons.work_outline_rounded,
            label: 'Task Group',
            value: taskGroup!.name,
            isDark: isDark,
            valueColor: accentColor,
          ),
      ],
    );
  }
}

// ── Info Card ──────────────────────────────────────────────────
class EmployeeInfoCard extends StatelessWidget {
  const EmployeeInfoCard({
    super.key,
    required this.isDark,
    required this.children,
  });

  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark
                      ? Colors.white.withAlpha(12)
                      : Colors.black.withAlpha(8),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Info Row ───────────────────────────────────────────────────
class EmployeeInfoRow extends StatelessWidget {
  const EmployeeInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.grey[500] : kTextMuted),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? (isDark ? Colors.white : kTextDark),
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

// ── Section Label ──────────────────────────────────────────────
class EmployeeDetailSectionLabel extends StatelessWidget {
  const EmployeeDetailSectionLabel({
    super.key,
    required this.label,
    required this.isDark,
  });

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: isDark ? Colors.grey[500] : kTextMuted,
      ),
    );
  }
}

// ── QR Code Section (read-only display) ───────────────────────
class EmployeeQrSection extends StatelessWidget {
  const EmployeeQrSection({super.key, required this.emp, required this.isDark});

  final Employee emp;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _QrNone(isDark: isDark),
    );
  }
}

// ── No QR state ────────────────────────────────────────────────
class _QrNone extends StatelessWidget {
  const _QrNone({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.qr_code_rounded,
          size: 64,
          color: isDark ? Colors.grey[700] : Colors.grey[300],
        ),
        const SizedBox(height: 10),
        Text(
          'No QR code generated yet',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[500] : kTextMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Use the card menu to generate a login QR code.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

// ── Tasks Section ──────────────────────────────────────────────
class EmployeeTasksSection extends StatelessWidget {
  const EmployeeTasksSection({
    super.key,
    required this.tasks,
    required this.isDark,
  });

  final List<TaskModel> tasks;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.task_outlined,
                size: 40,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Text(
                'No tasks assigned',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tasks.length, (i) {
          return Column(
            children: [
              _TaskRow(task: tasks[i], isDark: isDark),
              if (i < tasks.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.black.withAlpha(6),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.isDark});

  final TaskModel task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: task.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : kTextDark,
                    decoration: task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _Chip(label: task.statusLabel, color: task.statusColor),
                    _Chip(label: task.priorityLabel, color: task.priorityColor),
                    if (task.dueDate != null)
                      _DueChip(task: task, isDark: isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DueChip extends StatelessWidget {
  const _DueChip({required this.task, required this.isDark});

  final TaskModel task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = task.isOverdue
        ? kHighPriority
        : (isDark ? Colors.grey[500]! : Colors.grey[400]!);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          DateFormat('dd MMM').format(task.dueDate!),
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }
}

// ── Hero Header (for SliverAppBar FlexibleSpaceBar) ────────────
class EmployeeDetailHeroHeader extends StatelessWidget {
  const EmployeeDetailHeroHeader({
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

// ── Stats Row ──────────────────────────────────────────────────
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

// ── Action Buttons ─────────────────────────────────────────────
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

// ── Info List ──────────────────────────────────────────────────
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
