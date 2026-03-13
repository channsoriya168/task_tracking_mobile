import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_group_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/employee/admin_employee_detail_page.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/task_group/admin_task_group_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/employee_widgets.dart';

// ── Header ─────────────────────────────────────────────────────
class AdminEmployeeHeader extends StatelessWidget {
  const AdminEmployeeHeader({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

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
                  '${ctrl.employees.length} members',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => Get.to(() => const AdminTaskGroupPage()),
            icon: const Icon(Icons.work_outline_rounded, size: 16),
            label: const Text('Task Groups'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Group Dropdown ─────────────────────────────────────────────
class AdminEmployeeGroupDropdown extends StatelessWidget {
  const AdminEmployeeGroupDropdown({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final AdminEmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Obx(() {
        final tgCtrl = Get.find<AdminTaskGroupController>();
        final groups = tgCtrl.taskGroups.toList();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? kCardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: ctrl.selectedGroupId.value,
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
                        'All Groups',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                ...groups.map(
                  (g) => DropdownMenuItem(
                    value: g.id,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: g.color ?? kPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(g.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) => ctrl.selectedGroupId.value = val ?? '',
            ),
          ),
        );
      }),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────
class AdminEmployeeSearchBar extends StatelessWidget {
  const AdminEmployeeSearchBar({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

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
class AdminEmployeeList extends StatelessWidget {
  const AdminEmployeeList({
    super.key,
    required this.isDark,
    required this.ctrl,
  });

  final bool isDark;
  final AdminEmployeeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ctrl.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ctrl.errorMessage.value,
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: ctrl.fetchEmployees,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      final employees = ctrl.employees;
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
          final accentColor =
              employee.taskGroups.isNotEmpty
                  ? employee.taskGroups.first.groupColor
                  : kPrimary;
          return GestureDetector(
            onTap: () => Get.to(
              () => AdminEmployeeDetailPage(employeeId: employee.id),
            ),
            child: AdminEmployeeCard(
              isDark: isDark,
              employee: employee,
              accentColor: accentColor,
            ),
          );
        },
      );
    });
  }
}

// ── Employee Card ──────────────────────────────────────────────
class AdminEmployeeCard extends StatelessWidget {
  const AdminEmployeeCard({
    super.key,
    required this.isDark,
    required this.employee,
    required this.accentColor,
  });

  final bool isDark;
  final Employee employee;
  final Color accentColor;

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
      child: Row(
        children: [
          Stack(
            children: [
              EmployeeAvatar(
                name: employee.fullName,
                color: accentColor,
                radius: 22,
                imagePath: employee.profileImageUrl,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: employee.isActive
                        ? const Color(0xFF2ED573)
                        : const Color(0xFFFF4757),
                    border: Border.all(
                      color: isDark ? kCardDark : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  employee.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
                if (employee.taskGroups.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Obx(() {
                    final tgCtrl = Get.find<AdminTaskGroupController>();
                    return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: employee.taskGroups.map((g) {
                        final live = tgCtrl.taskGroups
                            .firstWhereOrNull((t) => t.id == g.groupId);
                        final name = live?.name ?? g.groupName;
                        final color = live?.color ?? g.groupColor;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
