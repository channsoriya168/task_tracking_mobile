import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/group/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_priority.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/dropdown_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/field_label_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_pickerField_widget.dart';

class TaskBottomSheet extends StatelessWidget {
  const TaskBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final groups = Get.find<GroupController>().groups.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Icon(
                      ctrl.editingTask.value != null
                          ? Icons.edit_note_rounded
                          : Icons.add_task_rounded,
                      color: kPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => Text(
                      ctrl.editingTask.value != null
                          ? 'task_form_edit'.tr
                          : 'task_form_new'.tr,
                      style: AppTextStyles.appBarTitle(color: kPrimary),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    size: 20,
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
          ),

          // ── Scrollable form ──────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      items: ctrl.labels.toList(),
                      label: (l) => l.name,
                      isDark: isDark,
                      onChanged: (l) => ctrl.selectedLabel.value = l,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  TextFieldWidget(
                    controller: ctrl.titleTextEditor,
                    label: 'task_form_title_label'.tr,
                    hint: 'task_form_title_hint'.tr,
                    isDark: isDark,
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),

                  // Description
                  TextFieldWidget(
                    controller: ctrl.descTextEditor,
                    label: 'task_form_desc_label'.tr,
                    hint: 'task_form_desc_hint'.tr,
                    isDark: isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 22),

                  // ── Section: Assignment ──────────────────
                  _SectionHeader(
                    label: 'task_form_section_assignment'.tr,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    isDark: isDark,
                    child: Row(
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
                              // Priority label + color dot
                              Obx(() {
                                final priorityName =
                                    ctrl.selectedPriority.value?.name ?? '';
                                final dot = kPriorityColors[priorityName];
                                return Row(
                                  children: [
                                    FieldLabelWidget(
                                      'task_detail_priority'.tr,
                                      isDark: isDark,
                                      isRequired: true,
                                    ),
                                    if (dot != null) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: dot,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                              const SizedBox(height: 8),
                              Obx(
                                () => DropdownWidget<TaskPriority>(
                                  value: ctrl.selectedPriority.value,
                                  items: ctrl.taskPriority.toList(),
                                  label: (p) => p.name,
                                  isDark: isDark,
                                  onChanged: (p) {
                                    if (p != null) {
                                      ctrl.selectedPriority.value = p;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Section: Schedule ────────────────────
                  _SectionHeader(
                    label: 'task_form_section_schedule'.tr,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Sticky submit button ─────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? kCardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Obx(() {
              final isEditing = ctrl.isEditing;
              final isSaving = ctrl.isSaving.value;
              return SizedBox(
                width: double.infinity,
                height: 52,
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
                    disabledBackgroundColor: kPrimary.withValues(alpha: 0.32),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'task_form_btn_update'.tr
                              : 'task_form_btn_create'.tr,
                          style: AppTextStyles.buttonLabel(color: Colors.white),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Section header with trailing divider ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kTextMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
        ),
      ],
    );
  }
}

// ── Lightly tinted card for grouped fields ────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : kSurfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
