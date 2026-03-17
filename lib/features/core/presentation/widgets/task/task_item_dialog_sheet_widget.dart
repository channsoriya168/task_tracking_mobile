import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/dropdown_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_pickerField_widget.dart';

class TaskItemDialogSheetWidget extends StatelessWidget {
  const TaskItemDialogSheetWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
    required this.groups,
    required this.outerContext,
  });

  final bool isDark;
  final TaskController ctrl;
  final List<TaskGroup> groups;
  final BuildContext outerContext;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kTextDark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(outerContext).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Obx(
                    () => Text(
                      ctrl.editingTask.value != null ? 'Edit Task' : 'New Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(outerContext),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Label
              _FieldLabel('Label', isDark: isDark, isRequired: true),
              const SizedBox(height: 8),
              Obx(
                () => DropdownWidget<Label>(
                  value: ctrl.selectedLabel.value,
                  items: ctrl.labels,
                  label: (l) => l.name,
                  isDark: isDark,
                  onChanged: (l) => ctrl.selectedLabel.value = l,
                ),
              ),
              const SizedBox(height: 14),

              TextFieldWidget(
                controller: ctrl.titleTextEditor,
                label: 'Title',
                hint: 'Enter task title',
                isDark: isDark,
                isRequired: true,
              ),
              const SizedBox(height: 14),

              TextFieldWidget(
                controller: ctrl.descTextEditor,
                label: 'Description',
                hint: 'Enter task description',
                isDark: isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // Group + Priority side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Group', isDark: isDark, isRequired: true),
                        const SizedBox(height: 8),
                        Obx(() {
                          final groupId = ctrl.selectedGroupId.value;
                          return DropdownWidget<TaskGroup>(
                            value: groups.firstWhereOrNull(
                              (g) => g.id == groupId,
                            ),
                            items: groups,
                            label: (g) => g.name,
                            isDark: isDark,
                            onChanged: (g) {
                              if (g != null) {
                                ctrl.selectedGroupId.value = g.id;
                                ctrl.selectedCategory.value = g.name;
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(
                          'Priority',
                          isDark: isDark,
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => DropdownWidget<TaskPriority>(
                            value: ctrl.selectedPriority.value,
                            items: ctrl.taskPriority,
                            label: (p) => p.name,
                            isDark: isDark,
                            onChanged: (p) {
                              if (p != null) ctrl.selectedPriority.value = p;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Due Date
              _FieldLabel('Due Date', isDark: isDark, isRequired: true),
              const SizedBox(height: 8),
              Obx(
                () => DatePickerFieldWidget(
                  isDark: isDark,
                  value: ctrl.selectedDueDate.value,
                  hint: 'Select due date',
                  firstDate: ctrl.currentDate.value ?? DateTime.now(),
                  onPick: (d) => ctrl.selectedDueDate.value = d,
                  onClear: () => ctrl.selectedDueDate.value = null,
                  context: outerContext,
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              Obx(() {
                // Read all .value upfront so every field is tracked
                // regardless of short-circuit evaluation.
                final title = ctrl.titleText.value.trim();
                final groupId = ctrl.selectedGroupId.value;
                final priority = ctrl.selectedPriority.value;
                final label = ctrl.selectedLabel.value;
                final dueDate = ctrl.selectedDueDate.value;
                final isEditing = ctrl.editingTask.value != null;
                final canSubmit =
                    title.isNotEmpty &&
                    groupId != null &&
                    priority != null &&
                    label != null &&
                    dueDate != null;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canSubmit
                        ? () async {
                            final ok = isEditing
                                ? await ctrl.updateTask()
                                : await ctrl.createTask();
                            if (ok && outerContext.mounted) {
                              Navigator.pop(outerContext);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kPrimary.withValues(alpha: 0.35),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Task' : 'Create Task',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.isDark, this.isRequired = false});
  final String text;
  final bool isDark;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: text.isNotEmpty
          ? TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : kTextDark,
              ),
              children: isRequired
                  ? [
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.red[400],
                        ),
                      ),
                    ]
                  : [],
            )
          : const TextSpan(),
    );
  }
}
