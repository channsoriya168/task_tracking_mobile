import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/data/models/employee.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_position_page.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/employee_dialogs.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/employee_widgets.dart';

class AdminEmployeeMobilePage extends StatelessWidget {
  const AdminEmployeeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        children: [
          _Header(isDark: isDark, ctrl: ctrl),
          EmployeeSearchBar(
            isDark: isDark,
            ctrl: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          ),
          Expanded(child: _EmployeeList(isDark: isDark, ctrl: ctrl)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => showEmployeeDialog(context, ctrl, isDark),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.isDark, required this.ctrl});

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Employees',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              Obx(() => Text(
                    '${ctrl.employees.length} members',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : kTextMuted,
                    ),
                  )),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => Get.to(() => const AdminPositionPage()),
            icon: const Icon(Icons.work_outline_rounded, size: 16),
            label: const Text('Positions'),
            style: TextButton.styleFrom(foregroundColor: kPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Employee List grouped by position ─────────────────────────
class _EmployeeList extends StatelessWidget {
  const _EmployeeList({required this.isDark, required this.ctrl});

  final bool isDark;
  final EmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final positions = ctrl.positions;
      if (positions.isEmpty) {
        return Center(
          child: Text(
            'No positions yet.\nTap "Positions" to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[500] : kTextMuted),
          ),
        );
      }

      final sections = positions
          .map((p) => (p, ctrl.employeesByPosition(p.id)))
          .where((s) => s.$2.isNotEmpty || ctrl.searchQuery.value.isEmpty)
          .toList();

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: sections.length,
        itemBuilder: (_, i) {
          final (position, emps) = sections[i];
          return _PositionSection(
            isDark: isDark,
            ctrl: ctrl,
            position: position,
            employees: emps,
          );
        },
      );
    });
  }
}

// ── Position Section ──────────────────────────────────────────
class _PositionSection extends StatefulWidget {
  const _PositionSection({
    required this.isDark,
    required this.ctrl,
    required this.position,
    required this.employees,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Position position;
  final List<Employee> employees;

  @override
  State<_PositionSection> createState() => _PositionSectionState();
}

class _PositionSectionState extends State<_PositionSection> {
  bool _expanded = true;

  bool get isDark => widget.isDark;

  @override
  Widget build(BuildContext context) {
    final p = widget.position;
    final emps = widget.employees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[300] : kTextMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: p.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${emps.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: p.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ],
            ),
          ),
        ),

        if (_expanded)
          ...emps.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EmployeeCard(
                isDark: isDark,
                ctrl: widget.ctrl,
                employee: e,
                position: p,
              ),
            ),
          ),

        if (_expanded && emps.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              'No employees in this position',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[600] : kTextMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Employee Card ─────────────────────────────────────────────
class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({
    required this.isDark,
    required this.ctrl,
    required this.employee,
    required this.position,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final Position position;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(employee.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withAlpha(200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ctrl.deleteEmployee(employee.id),
      child: GestureDetector(
        onTap: () => showEmployeeDialog(context, ctrl, isDark, employee),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 40 : 10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: EmployeeCardContent(
            employee: employee,
            accentColor: position.color,
            isDark: isDark,
            avatarRadius: 22,
            nameFontSize: 14,
            emailFontSize: 12,
            trailingIcon: Icons.edit_rounded,
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Remove "${employee.name}" from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: kHighPriority),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}