import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/user_avatar_widget.dart';

class EmployeePickerSheet extends StatefulWidget {
  const EmployeePickerSheet({
    super.key,
    required this.employees,
    required this.isDark,
  });

  final List<Employee> employees;
  final bool isDark;

  @override
  State<EmployeePickerSheet> createState() => _EmployeePickerSheetState();
}

class _EmployeePickerSheetState extends State<EmployeePickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.employees
        .where((e) => e.fullName.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    final bg = widget.isDark ? kCardDark : Colors.white;
    final textColor = widget.isDark ? Colors.white : kTextDark;
    final mutedColor = widget.isDark ? Colors.white38 : kTextMuted;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'picker_select_employee'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'picker_search_hint'.tr,
                hintStyle: TextStyle(color: mutedColor),
                prefixIcon: Icon(Icons.search, color: mutedColor, size: 18),
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'picker_empty'.tr,
                      style: TextStyle(color: mutedColor),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (_, i) {
                      final emp = filtered[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: UserAvatarWidget(
                          name: emp.fullName,
                          imageUrl: emp.profileImageUrl,
                          radius: 18,
                        ),
                        title: Text(
                          emp.fullName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          emp.email,
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                        onTap: () => Navigator.pop(context, emp),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
