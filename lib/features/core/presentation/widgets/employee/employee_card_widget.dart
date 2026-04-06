// ── Employee Card + Role Badge ────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_menu_sheet.dart';

class EmployeeCardWidget extends StatelessWidget {
  const EmployeeCardWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
    required this.employee,
    this.taskGroup,
  });

  final bool isDark;
  final EmployeeController ctrl;
  final Employee employee;
  final Group? taskGroup;

  String? _genderName() {
    if (employee.genderId == null) return null;
    final match = ctrl.genders.where((g) => g.id == employee.genderId).toList();
    return match.isNotEmpty ? match.first.name : null;
  }

  bool get _isProtected {
    final authRole = Get.find<AuthController>().role;
    if (authRole != UserRole.manager) return false;
    final r = employee.role?.toLowerCase() ?? '';
    return r == 'manager' || r == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    const accent = kPrimary;
    final protected = _isProtected;
    final hasPhone = employee.phone != null && employee.phone!.isNotEmpty;
    final hasGroups = employee.groups.isNotEmpty || taskGroup != null;
    final genderName = _genderName();

    return GestureDetector(
      onTap: () => showEmployeeMenuSheet(
        context,
        employeeId: employee.id,
        ctrl: ctrl,
        isDark: isDark,
        accentColor: accent,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.grey.withAlpha(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            if (!isDark)
              BoxShadow(
                color: kPrimary.withAlpha(18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar ────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withAlpha(18) : Colors.white,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(30)
                            : kPrimary.withAlpha(40),
                        width: 2,
                      ),
                    ),
                    child: EmployeeAvatarWidget(
                      name: employee.fullName,
                      color: kPrimary,
                      radius: 26,
                      imagePath: employee.profileImageUrl,
                    ),
                  ),
                ),
                if (protected)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? kCardDark : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withAlpha(80),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + inactive
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          employee.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : kTextDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Role label (colored)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        employee.role ?? 'employee_no_role'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),

                  // Gender
                  if (genderName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.wc_rounded,
                          size: 11,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          genderName,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Phone
                  if (hasPhone) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 11,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            employee.phone!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Group badges
                  if (hasGroups) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (employee.groups.isNotEmpty)
                          ...employee.groups
                              .take(2)
                              .map(
                                (g) => _GroupChip(
                                  name: g.groupName,
                                  isDark: isDark,
                                ),
                              )
                        else if (taskGroup != null)
                          _GroupChip(name: taskGroup!.name, isDark: isDark),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Chevron ───────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(10)
                    : Colors.grey.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Group Chip ────────────────────────────────────────────────
class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.name, required this.isDark});
  final String name;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? Colors.white.withAlpha(14) : kPrimary.withAlpha(18);
    final border = isDark ? Colors.white.withAlpha(28) : kPrimary.withAlpha(55);
    final dotColor = isDark ? Colors.white.withAlpha(140) : kPrimary;
    final textColor = isDark
        ? Colors.white.withAlpha(180)
        : const Color(0xFF4B47CC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
