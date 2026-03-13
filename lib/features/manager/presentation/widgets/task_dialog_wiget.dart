import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/dropdown_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';

Future<void> showTaskDetailSheet(
  BuildContext context,
  bool isDark,
  TaskItem task,
  ManagerTaskController controller,
) async {
  final posCtrl = Get.find<TaskGroupController>();
  final taskGroup = task.groupId != null
      ? posCtrl.findPosition(task.groupId!)
      : null;
  final positionColor = taskGroup?.color ?? kPrimary;
  final textColor = isDark ? Colors.white : kTextDark;
  final mutedColor = isDark ? Colors.white38 : kTextMuted;
  final divColor = isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
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

            // Status + priority row
            Row(
              children: [
                _DetailBadge(
                  label: task.statusLabel,
                  color: task.statusColor,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _DetailBadge(
                  label: task.priorityLabel,
                  color: task.priorityColor,
                  isDark: isDark,
                ),
                const Spacer(),
                if (task.dueDate != null)
                  Row(
                    children: [
                      Icon(
                        task.isOverdue
                            ? Icons.error_outline_rounded
                            : Icons.calendar_today_rounded,
                        size: 13,
                        color: task.isOverdue ? kHighPriority : mutedColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isOverdue ? kHighPriority : mutedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              task.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.3,
              ),
            ),

            // Description
            if ((task.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                task.description ?? '',
                style: TextStyle(fontSize: 14, color: mutedColor, height: 1.6),
              ),
            ],

            const SizedBox(height: 20),
            Divider(height: 1, color: divColor),
            const SizedBox(height: 20),

            // Position
            _DetailRow(
              icon: Icons.work_outline_rounded,
              label: 'Position',
              isDark: isDark,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: positionColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: positionColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  task.groupName ?? task.labelName ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: positionColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Accepted by
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Accepted by',
              isDark: isDark,
              child: task.assignedToName != null
                  ? Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(
                              alpha: isDark ? 0.25 : 0.12,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            task.assignedToName![0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: kPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.assignedToName!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Not accepted yet',
                      style: TextStyle(fontSize: 14, color: mutedColor),
                    ),
            ),
            const SizedBox(height: 16),

            // Created
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: 'Created',
              isDark: isDark,
              child: Text(
                _formatDate(task.createdAt ?? DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({
    required this.label,
    required this.color,
    required this.isDark,
  });
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.child,
  });
  final IconData icon;
  final String label;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(fontSize: 13, color: mutedColor)),
        ),
        Expanded(child: child),
      ],
    );
  }
}

Future<void> showTaskDialog(
  BuildContext context,
  bool isDark, {
  TaskItem? task,
}) async {
  final ctrl = Get.find<ManagerTaskController>();
  final posCtrl = Get.find<TaskGroupController>();
  final groups = posCtrl.taskGroups;
  final isEditMode = task != null;

  // Pre-populate form
  if (isEditMode) {
    ctrl.titleTextEditor.text = task.title;
    ctrl.descTextEditor.text = task.description ?? '';
    ctrl.selectedGroupId.value = task.groupId;
    ctrl.selectedCategory.value = task.groupName ?? '';
    ctrl.selectedPriority.value = task.priority;
    ctrl.selectedDueDate.value = task.dueDate;
  } else {
    ctrl.titleTextEditor.clear();
    ctrl.descTextEditor.clear();
    ctrl.selectedGroupId.value = groups.isNotEmpty ? groups.first.id : null;
    ctrl.selectedCategory.value =
        groups.isNotEmpty ? groups.first.name : '';
    ctrl.selectedPriority.value = ctrl.availablePriorities.isNotEmpty
        ? (ctrl.availablePriorities.firstWhereOrNull(
              (p) => p.name.toLowerCase() == 'medium',
            ) ??
            ctrl.availablePriorities.first)
        : null;
    ctrl.selectedDueDate.value = null;
  }

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
                isEditMode ? 'Edit Task' : 'New Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextFieldWidget(
                controller: ctrl.titleTextEditor,
                label: 'Title',
                hint: 'Task title',
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Description
              TextFieldWidget(
                controller: ctrl.descTextEditor,
                label: 'Description',
                hint: 'Optional description',
                isDark: isDark,
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

              // Priority
              _Label('Priority', isDark: isDark),
              const SizedBox(height: 8),
              Obx(() => DropdownWidget<TaskPriority>(
                    value: ctrl.selectedPriority.value,
                    items: ctrl.availablePriorities.toList(),
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
                  )),
              const SizedBox(height: 16),

              // Due Date
              _Label('Due Date', isDark: isDark),
              const SizedBox(height: 8),
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: ctrl.selectedDueDate.value ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) ctrl.selectedDueDate.value = picked;
                  },
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                          size: 16,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ctrl.selectedDueDate.value == null
                              ? 'No due date'
                              : _formatDate(ctrl.selectedDueDate.value!),
                          style: TextStyle(
                            fontSize: 14,
                            color: ctrl.selectedDueDate.value == null
                                ? (isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400])
                                : (isDark ? Colors.white : kTextDark),
                          ),
                        ),
                        const Spacer(),
                        if (ctrl.selectedDueDate.value != null)
                          GestureDetector(
                            onTap: () => ctrl.selectedDueDate.value = null,
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: isDark ? Colors.grey[500] : kTextMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Create / Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = ctrl.titleTextEditor.text.trim();
                    if (title.isEmpty) return;

                    if (isEditMode) {
                      final updatedTask = task.copyWith(
                        title: title,
                        description: ctrl.descTextEditor.text.trim(),
                        groupId: ctrl.selectedGroupId.value,
                        groupName: ctrl.selectedCategory.value,
                        priority: ctrl.selectedPriority.value,
                        dueDate: ctrl.selectedDueDate.value,
                        clearDueDate: ctrl.selectedDueDate.value == null,
                      );
                      await ctrl.updateTask(updatedTask);
                    } else {
                      await ctrl.createTask();
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditMode ? 'Update Task' : 'Create Task',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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

String _formatDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
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
