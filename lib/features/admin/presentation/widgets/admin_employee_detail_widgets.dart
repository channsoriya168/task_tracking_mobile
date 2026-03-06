import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';

// ── Header card ──────────────────────────────────────────────────

class EmployeeDetailHeader extends StatelessWidget {
  const EmployeeDetailHeader({
    super.key,
    required this.employee,
    required this.position,
    required this.isDark,
  });

  final Employee employee;
  final Position? position;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = position?.color ?? kPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.6 : 0.85),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          EmployeeAvatar(
            name: employee.name,
            color: Colors.white,
            radius: 36,
            imagePath: employee.imagePath,
          ),
          const SizedBox(height: 14),
          Text(
            employee.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            employee.email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          if (position != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
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
                    position!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Info card ────────────────────────────────────────────────────

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
    return _SectionCard(
      isDark: isDark,
      borderColor: borderColor,
      cardBg: cardBg,
      label: 'Contact Info',
      child: Column(
        children: [
          if (employee.phone != null)
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: employee.phone!,
              isDark: isDark,
              borderColor: borderColor,
              showDivider: employee.dateOfBirth != null ||
                  employee.placeOfBirth != null,
            ),
          if (employee.dateOfBirth != null)
            _InfoRow(
              icon: Icons.cake_outlined,
              label: 'Date of Birth',
              value: _formatDate(employee.dateOfBirth!),
              isDark: isDark,
              borderColor: borderColor,
              showDivider: employee.placeOfBirth != null,
            ),
          if (employee.placeOfBirth != null)
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Place of Birth',
              value: employee.placeOfBirth!,
              isDark: isDark,
              borderColor: borderColor,
              showDivider: false,
            ),
          if (employee.phone == null &&
              employee.dateOfBirth == null &&
              employee.placeOfBirth == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No contact info available.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white30 : kTextMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.borderColor,
    required this.showDivider,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color borderColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kPrimary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : kTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : kTextDark,
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
            indent: 50,
            color: isDark ? Colors.white12 : Colors.grey.shade100,
          ),
      ],
    );
  }
}

// ── Assigned tasks card ──────────────────────────────────────────

class EmployeeAssignedTasksCard extends StatelessWidget {
  const EmployeeAssignedTasksCard({
    super.key,
    required this.tasks,
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
  });

  final List<TaskModel> tasks;
  final bool isDark;
  final Color borderColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      isDark: isDark,
      borderColor: borderColor,
      cardBg: cardBg,
      label: 'Assigned Tasks',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: kPrimary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${tasks.length}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kPrimary,
          ),
        ),
      ),
      child: tasks.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No tasks assigned yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white30 : kTextMuted,
                ),
              ),
            )
          : Column(
              children: tasks
                  .map((t) => _TaskRow(task: t, isDark: isDark))
                  .toList(),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: task.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: task.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: task.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared section card ──────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.borderColor,
    required this.cardBg,
    required this.label,
    required this.child,
    this.trailing,
  });

  final bool isDark;
  final Color borderColor;
  final Color cardBg;
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: isDark ? Colors.white70 : const Color(0xFF374151),
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
