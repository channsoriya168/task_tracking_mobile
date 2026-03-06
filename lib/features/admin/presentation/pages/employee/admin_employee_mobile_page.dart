import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/employee/admin_employee_detail_page.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

class AdminEmployeeMobilePage extends StatelessWidget {
  const AdminEmployeeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminEmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Column(
        children: [
          _AdminEmployeeHeader(isDark: isDark, ctrl: ctrl),
          _PositionDropdown(isDark: isDark, ctrl: ctrl),
          _AdminEmployeeSearchBar(isDark: isDark, ctrl: ctrl),
          Expanded(
            child: _AdminEmployeeList(isDark: isDark, ctrl: ctrl),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────
class _AdminEmployeeHeader extends StatelessWidget {
  const _AdminEmployeeHeader({required this.isDark, required this.ctrl});

  final bool isDark;
  final AdminEmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              Obx(
                () => Text(
                  '${ctrl.filteredEmployees.length} of ${ctrl.employees.length} members',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Position Dropdown ──────────────────────────────────────────
class _PositionDropdown extends StatelessWidget {
  const _PositionDropdown({required this.isDark, required this.ctrl});

  final bool isDark;
  final AdminEmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Obx(() {
        final positions = ctrl.positions;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: ctrl.selectedPositionId.value,
              dropdownColor: isDark ? kCardDark : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.grey[500] : kTextMuted,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : kTextDark,
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 18,
                        color: isDark ? Colors.grey[500] : kTextMuted,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'All Positions',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                ...positions.map(
                  (p) => DropdownMenuItem(
                    value: p.id,
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
                        const SizedBox(width: 10),
                        Text(p.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) => ctrl.selectedPositionId.value = val ?? '',
            ),
          ),
        );
      }),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────
class _AdminEmployeeSearchBar extends StatelessWidget {
  const _AdminEmployeeSearchBar({required this.isDark, required this.ctrl});

  final bool isDark;
  final AdminEmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: TextField(
        onChanged: (v) => ctrl.searchQuery.value = v,
        style: TextStyle(color: isDark ? Colors.white : kTextDark),
        decoration: InputDecoration(
          hintText: 'Search employees...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : kTextMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.grey[600] : kTextMuted,
            size: 20,
          ),
          filled: true,
          fillColor: isDark ? kCardDark : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ── Employee List ──────────────────────────────────────────────
class _AdminEmployeeList extends StatelessWidget {
  const _AdminEmployeeList({required this.isDark, required this.ctrl});

  final bool isDark;
  final AdminEmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final employees = ctrl.filteredEmployees;
      if (employees.isEmpty) {
        return Center(
          child: Text(
            'No employees found.',
            style: TextStyle(color: isDark ? Colors.grey[500] : kTextMuted),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: employees.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final employee = employees[i];
          final position = ctrl.findPosition(employee.positionId);
          final accentColor = position?.color ?? kPrimary;
          return GestureDetector(
            onTap: () => Get.to(() => AdminEmployeeDetailPage(
                  employee: employee,
                  position: position,
                )),
            child: _AdminEmployeeCard(
              isDark: isDark,
              employee: employee,
              accentColor: accentColor,
              position: position,
            ),
          );
        },
      );
    });
  }
}

// ── Employee Card ──────────────────────────────────────────────
class _AdminEmployeeCard extends StatelessWidget {
  const _AdminEmployeeCard({
    required this.isDark,
    required this.employee,
    required this.accentColor,
    required this.position,
  });

  final bool isDark;
  final Employee employee;
  final Color accentColor;
  final Position? position;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        accentColor: accentColor,
        isDark: isDark,
        avatarRadius: 22,
        nameFontSize: 14,
        emailFontSize: 12,
        trailingIcon: Icons.chevron_right_rounded,
        position: position,
      ),
    );
  }
}
