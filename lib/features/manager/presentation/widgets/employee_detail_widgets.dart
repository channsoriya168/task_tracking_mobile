import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

// ── Profile Header ─────────────────────────────────────────────
class EmployeeDetailHeader extends StatelessWidget {
  const EmployeeDetailHeader({
    super.key,
    required this.emp,
    required this.accentColor,
    required this.isDark,
    required this.pos,
  });

  final Employee emp;
  final Color accentColor;
  final bool isDark;
  final Position? pos;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 14),
          Text(
            emp.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          if (pos != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pos!.name,
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
    final path = emp.imagePath;
    final isLocal = path != null && path.isNotEmpty && !path.startsWith('http');
    final isNetwork = path != null && path.startsWith('http');

    return CircleAvatar(
      radius: 48,
      backgroundColor: accentColor.withAlpha(40),
      backgroundImage: isLocal
          ? FileImage(File(path))
          : isNetwork
              ? NetworkImage(path) as ImageProvider
              : null,
      child: (path == null || path.isEmpty)
          ? Text(
              employeeInitials(emp.name),
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
    required this.pos,
  });

  final Employee emp;
  final bool isDark;
  final Color accentColor;
  final Position? pos;

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
        if (pos != null)
          EmployeeInfoRow(
            icon: Icons.work_outline_rounded,
            label: 'Position',
            value: pos!.name,
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
  const EmployeeQrSection({
    super.key,
    required this.emp,
    required this.isDark,
  });

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
      child: emp.hasQr ? _QrDisplay(emp: emp, isDark: isDark) : _QrNone(isDark: isDark),
    );
  }
}

// ── QR Display ─────────────────────────────────────────────────
class _QrDisplay extends StatelessWidget {
  const _QrDisplay({required this.emp, required this.isDark});

  final Employee emp;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isExpired = emp.isQrExpired;
    final expiresAt = emp.qrExpiresAt;

    return Column(
      children: [
        // QR image — grayscale + EXPIRED label when expired
        Stack(
          alignment: Alignment.center,
          children: [
            if (isExpired)
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
                child: QrImageView(
                  data: emp.qrCode!,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              )
            else
              QrImageView(
                data: emp.qrCode!,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            if (isExpired)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kHighPriority,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'EXPIRED',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Status + expiry info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isExpired ? kHighPriority : kLowPriority,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isExpired ? 'Expired' : 'Active',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isExpired ? kHighPriority : kLowPriority,
              ),
            ),
            if (expiresAt != null) ...[
              Text(
                '  ·  ',
                style: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              Text(
                isExpired
                    ? 'Expired ${DateFormat('dd MMM yyyy').format(expiresAt)}'
                    : 'Expires ${DateFormat('dd MMM yyyy').format(expiresAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ),
            ],
          ],
        ),

        if (isExpired) ...[
          const SizedBox(height: 10),
          Text(
            'Go back and use the menu to reset.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ],
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
                    _Chip(
                      label: task.statusLabel,
                      color: task.statusColor,
                    ),
                    _Chip(
                      label: task.priorityLabel,
                      color: task.priorityColor,
                    ),
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