import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/data/models/employee.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/employee_dialogs.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/employee_widgets.dart';

class AdminEmployeeTabletPage extends StatefulWidget {
  const AdminEmployeeTabletPage({super.key});

  @override
  State<AdminEmployeeTabletPage> createState() =>
      _AdminEmployeeTabletPageState();
}

class _AdminEmployeeTabletPageState extends State<AdminEmployeeTabletPage> {
  String? _selectedPositionId;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? kBgDark : kBgLight,
      child: Row(
        children: [
          // ── Left Panel: Positions ─────────────────────────
          SizedBox(
            width: 260,
            child: _PositionsPanel(
              isDark: isDark,
              ctrl: ctrl,
              selectedId: _selectedPositionId,
              onSelect: (id) => setState(() => _selectedPositionId = id),
            ),
          ),

          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),

          // ── Right Panel: Employees ────────────────────────
          Expanded(
            child: _EmployeesPanel(
              isDark: isDark,
              ctrl: ctrl,
              selectedPositionId: _selectedPositionId,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Left Panel ─────────────────────────────────────────────────
class _PositionsPanel extends StatelessWidget {
  const _PositionsPanel({
    required this.isDark,
    required this.ctrl,
    required this.selectedId,
    required this.onSelect,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? kSurfaceDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 4),
            child: Row(
              children: [
                Text(
                  'Positions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => showPositionDialog(context, ctrl, isDark),
                  icon: Icon(Icons.add_rounded, color: kPrimary, size: 22),
                  tooltip: 'Add Position',
                ),
              ],
            ),
          ),

          // "All" option
          Obx(() {
            final totalCount = ctrl.employees.length;
            return _PositionTile(
              isDark: isDark,
              label: 'All Employees',
              count: totalCount,
              color: kPrimary,
              icon: Icons.people_rounded,
              selected: selectedId == null,
              onTap: () => onSelect(null),
            );
          }),

          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'GROUPS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Position list
          Expanded(
            child: Obx(() {
              final positions = ctrl.positions;
              if (positions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No positions yet.\nTap + to create one.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[600] : kTextMuted,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: positions.length,
                itemBuilder: (_, i) {
                  final pos = positions[i];
                  final count = ctrl.employeeCountByPosition(pos.id);
                  return Dismissible(
                    key: ValueKey(pos.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: kHighPriority.withAlpha(180),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    confirmDismiss: (_) => _confirmDelete(context, pos, count),
                    onDismissed: (_) {
                      if (selectedId == pos.id) onSelect(null);
                      ctrl.deletePosition(pos.id);
                    },
                    child: GestureDetector(
                      onLongPress: () =>
                          showPositionDialog(context, ctrl, isDark, pos),
                      child: _PositionTile(
                        isDark: isDark,
                        label: pos.name,
                        count: count,
                        color: pos.color,
                        icon: Icons.work_rounded,
                        selected: selectedId == pos.id,
                        onTap: () => onSelect(pos.id),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Position pos, int count) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Position'),
        content: Text(
          count > 0
              ? 'This removes $count ${count == 1 ? 'employee' : 'employees'} in "${pos.name}". Continue?'
              : 'Delete position "${pos.name}"?',
        ),
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

// ── Position Tile ─────────────────────────────────────────────
class _PositionTile extends StatelessWidget {
  const _PositionTile({
    required this.isDark,
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final bool isDark;
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withAlpha(selected ? 50 : 25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? color
                      : (isDark ? Colors.grey[300] : kTextDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(selected ? 50 : 20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Right Panel ────────────────────────────────────────────────
class _EmployeesPanel extends StatelessWidget {
  const _EmployeesPanel({
    required this.isDark,
    required this.ctrl,
    required this.selectedPositionId,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final String? selectedPositionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PanelHeader(
          isDark: isDark,
          ctrl: ctrl,
          selectedPositionId: selectedPositionId,
        ),
        EmployeeSearchBar(
          isDark: isDark,
          ctrl: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        ),
        Expanded(
          child: Obx(() {
            final employees = selectedPositionId == null
                ? ctrl.filteredEmployees
                : ctrl.employeesByPosition(selectedPositionId!);

            if (employees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search_rounded,
                      size: 56,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ctrl.searchQuery.value.isNotEmpty
                          ? 'No results found'
                          : 'No employees here yet',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 88,
              ),
              itemCount: employees.length,
              itemBuilder: (_, i) {
                final emp = employees[i];
                final pos = ctrl.findPosition(emp.positionId);
                return _EmployeeGridCard(
                  isDark: isDark,
                  ctrl: ctrl,
                  employee: emp,
                  position: pos,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// ── Panel Header ──────────────────────────────────────────────
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.isDark,
    required this.ctrl,
    required this.selectedPositionId,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final String? selectedPositionId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pos = selectedPositionId != null
          ? ctrl.findPosition(selectedPositionId!)
          : null;
      final title = pos?.name ?? 'All Employees';
      final count = selectedPositionId == null
          ? ctrl.employees.length
          : ctrl.employeeCountByPosition(selectedPositionId!);

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 16, 4),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                Text(
                  '$count ${count == 1 ? 'member' : 'members'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => showEmployeeDialog(context, ctrl, isDark),
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text('Add Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      );
    });
  }
}

// ── Employee Grid Card ────────────────────────────────────────
class _EmployeeGridCard extends StatelessWidget {
  const _EmployeeGridCard({
    required this.isDark,
    required this.ctrl,
    required this.employee,
    required this.position,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final Position? position;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showEmployeeDialog(context, ctrl, isDark, employee),
      onLongPress: () => _confirmDelete(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 35 : 8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: EmployeeCardContent(
          employee: employee,
          accentColor: position?.color ?? kPrimary,
          isDark: isDark,
          avatarRadius: 20,
          nameFontSize: 13,
          emailFontSize: 11,
          trailingIcon: Icons.more_vert_rounded,
          position: position,
          clampText: true,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Employee'),
        content: Text('Remove "${employee.name}" from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ctrl.deleteEmployee(employee.id);
            },
            style: TextButton.styleFrom(foregroundColor: kHighPriority),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}