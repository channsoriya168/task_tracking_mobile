import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/dropdown_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/field_label_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_pickerField_widget.dart';

class TaskItemDialogSheetWidget extends StatelessWidget {
  const TaskItemDialogSheetWidget({
    super.key,
    required this.isDark,
    required this.ctrl,
    required this.groups,
  });

  final bool isDark;
  final TaskController ctrl;
  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kTextDark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      ctrl.editingTask.value != null
                          ? 'task_form_edit'.tr
                          : 'task_form_new'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
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
              FieldLabelWidget(
                'task_detail_label'.tr,
                isDark: isDark,
                isRequired: true,
              ),
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
                label: 'task_form_title_label'.tr,
                hint: 'task_form_title_hint'.tr,
                isDark: isDark,
                isRequired: true,
              ),
              const SizedBox(height: 14),

              TextFieldWidget(
                controller: ctrl.descTextEditor,
                label: 'task_form_desc_label'.tr,
                hint: 'task_form_desc_hint'.tr,
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
                        FieldLabelWidget(
                          'task_detail_group'.tr,
                          isDark: isDark,
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final groupId = ctrl.selectedGroupId.value;
                          return DropdownWidget<Group>(
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
                        FieldLabelWidget(
                          'task_detail_priority'.tr,
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
              FieldLabelWidget(
                'task_detail_due_date'.tr,
                isDark: isDark,
                isRequired: true,
              ),
              const SizedBox(height: 8),
              Obx(
                () => DatePickerFieldWidget(
                  isDark: isDark,
                  value: ctrl.selectedDueDate.value,
                  hint: 'task_form_due_date_hint'.tr,
                  firstDate: ctrl.currentDate.value ?? DateTime.now(),
                  onPick: (d) => ctrl.selectedDueDate.value = d,
                  onClear: () => ctrl.selectedDueDate.value = null,
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              Obx(() {
                final isEditing = ctrl.isEditing;
                final isSaving = ctrl.isSaving.value;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ctrl.canSubmit && !isSaving
                        ? () async {
                            final ok = isEditing
                                ? await ctrl.updateTask()
                                : await ctrl.createTask();
                            if (ok) Get.back();
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
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            isEditing
                                ? 'task_form_btn_update'.tr
                                : 'task_form_btn_create'.tr,
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
