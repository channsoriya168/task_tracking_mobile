import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/dropdown_widget.dart';

Future<void> showAdminTaskDialog(BuildContext context, bool isDark) async {
  final ctrl = Get.find<AdminTaskController>();
  final groupCtrl = Get.find<AdminTaskGroupController>();
  final groups = groupCtrl.taskGroups;

  // Reset form state
  ctrl.selectedLabel.value = null;
  ctrl.selectedGroupId.value = groups.isNotEmpty ? groups.first.id : null;
  ctrl.selectedPriority.value = ctrl.taskPriority.isNotEmpty
      ? (ctrl.taskPriority.firstWhereOrNull(
              (p) => p.name.toLowerCase() == 'medium',
            ) ??
            ctrl.taskPriority.first)
      : null;
  ctrl.selectedStartDate.value = null;
  ctrl.selectedDueDate.value = null;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'New Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 20),

              // Label (required)
              _Label('Label *', isDark: isDark),
              const SizedBox(height: 8),
              Obx(
                () => DropdownWidget<Label>(
                  value: ctrl.selectedLabel.value,
                  items: ctrl.labels.toList(),
                  label: (l) => l.name,
                  isDark: isDark,
                  onChanged: (l) => ctrl.selectedLabel.value = l,
                  leadingBuilder: (l) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: l.color != null ? _hexColor(l.color!) : kPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Group
              _Label('Group', isDark: isDark),
              const SizedBox(height: 8),
              Obx(() {
                final selected = groups.firstWhereOrNull(
                  (g) => g.id == ctrl.selectedGroupId.value,
                );
                return DropdownWidget<TaskGroup>(
                  value: selected,
                  items: groups.toList(),
                  label: (g) => g.name,
                  isDark: isDark,
                  onChanged: (g) {
                    if (g != null) {
                      ctrl.selectedGroupId.value = g.id;
                      ctrl.selectedCategory.value = g.name;
                    }
                  },
                  leadingBuilder: (g) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: g.color ?? kPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Priority (required)
              _Label('Priority *', isDark: isDark),
              const SizedBox(height: 8),
              Obx(
                () => DropdownWidget<TaskPriority>(
                  value: ctrl.selectedPriority.value,
                  items: ctrl.taskPriority.toList(),
                  label: (p) => p.name,
                  isDark: isDark,
                  onChanged: (p) {
                    if (p != null) ctrl.selectedPriority.value = p;
                  },
                  leadingBuilder: (p) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Start Date & Due Date side by side
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Start Date', isDark: isDark),
                        const SizedBox(height: 8),
                        Obx(
                          () => _DatePickerField(
                            isDark: isDark,
                            value: ctrl.selectedStartDate.value,
                            hint: 'Start',
                            onPick: (picked) =>
                                ctrl.selectedStartDate.value = picked,
                            onClear: () => ctrl.selectedStartDate.value = null,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Due Date', isDark: isDark),
                        const SizedBox(height: 8),
                        Obx(
                          () => _DatePickerField(
                            isDark: isDark,
                            value: ctrl.selectedDueDate.value,
                            hint: 'Due',
                            onPick: (picked) =>
                                ctrl.selectedDueDate.value = picked,
                            onClear: () => ctrl.selectedDueDate.value = null,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Create button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (ctrl.selectedLabel.value == null ||
                                ctrl.selectedPriority.value == null)
                            ? null
                            : () async {
                                await ctrl.createTask();
                                if (context.mounted) Navigator.pop(context);
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kPrimary.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Task',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Color _hexColor(String hex) {
  final clean = hex.replaceFirst('#', '');
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return kPrimary;
  return Color(0xFF000000 | value);
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[400] : kTextMuted,
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.isDark,
    required this.value,
    required this.hint,
    required this.onPick,
    required this.onClear,
    required this.context,
  });

  final bool isDark;
  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime> onPick;
  final VoidCallback onClear;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 730)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: kPrimary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : kBgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: isDark ? Colors.grey[500] : kTextMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null ? hint : _formatDate(value!),
                style: TextStyle(
                  fontSize: 13,
                  color: value == null
                      ? (isDark ? Colors.grey[600] : Colors.grey[400])
                      : (isDark ? Colors.white : kTextDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
