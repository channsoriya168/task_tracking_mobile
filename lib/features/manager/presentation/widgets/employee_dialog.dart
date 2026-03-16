import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_picker_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';

// ── Sheet ──────────────────────────────────────────────────────
class EmployeeDialogSheet extends StatelessWidget {
  const EmployeeDialogSheet({super.key, required this.controller});

  final EmployeeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            Text(
              controller.existing == null ? 'Add Employee' : 'Edit Employee',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ───────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => controller.showImagePickerOptions(),
                        child: Obx(() {
                          final path = controller.formImagePath.value;
                          return Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: kPrimary.withAlpha(40),
                                backgroundImage: path != null
                                    ? FileImage(File(path))
                                    : null,
                                child: path == null
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 36,
                                        color: kPrimary,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: kPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: controller.nameCtrl,
                      label: 'Full Name',
                      hint: 'e.g. Alice Johnson',
                      isDark: isDark,
                      isRequired: true,
                    ),
                    const SizedBox(height: 14),
                    TextFieldWidget(
                      controller: controller.emailCtrl,
                      label: 'Email',
                      hint: 'e.g. alice@company.com',
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    TextFieldWidget(
                      controller: controller.phoneCtrl,
                      label: 'Phone',
                      hint: 'e.g. +855 12 345 678',
                      isDark: isDark,
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                    ),
                    if (controller.existing == null) ...[
                      const SizedBox(height: 14),
                      Obx(() {
                        final visible = controller.formPasswordVisible.value;
                        return TextFieldWidget(
                          controller: controller.passwordCtrl,
                          label: 'Password',
                          hint: 'Enter password',
                          isDark: isDark,
                          obscureText: !visible,
                          isRequired: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              visible
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                            onPressed: () => controller
                                .formPasswordVisible.value = !visible,
                          ),
                        );
                      }),
                      const SizedBox(height: 14),
                      Obx(() {
                        final visible =
                            controller.formConfirmPasswordVisible.value;
                        return TextFieldWidget(
                          controller: controller.confirmPasswordCtrl,
                          label: 'Confirm Password',
                          hint: 'Re-enter password',
                          isDark: isDark,
                          obscureText: !visible,
                          isRequired: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              visible
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                            onPressed: () => controller
                                .formConfirmPasswordVisible.value = !visible,
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 14),
                    DatePickerWidget(
                      isDark: isDark,
                      value: controller.formDob,
                      onPicked: (d) => controller.formDob.value = d,
                      label: 'Select date of birth',
                      isRequired: true,
                    ),
                    const SizedBox(height: 14),
                    TextFieldWidget(
                      controller: controller.placeCtrl,
                      label: 'Place of Birth',
                      hint: 'e.g. Phnom Penh',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _TaskGroupPicker(
                      isDark: isDark,
                      taskGroups: controller.taskGroups,
                      formGroupIds: controller.formGroupIds,
                      onAddTaskGroup: () =>
                          controller.onOpenTaskGroupDialog(context),
                      onToggleTaskGroup: (id) {
                        if (controller.formGroupIds.contains(id)) {
                          controller.formGroupIds.remove(id);
                        } else {
                          controller.formGroupIds.add(id);
                        }
                      },
                      isRequired: true,
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      final enabled = controller.isFormValid;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: enabled
                              ? () => controller.saveEmployee()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: kPrimary.withAlpha(80),
                            disabledForegroundColor:
                                Colors.white.withAlpha(120),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            controller.existing == null
                                ? 'Add Employee'
                                : 'Save Changes',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Task Group Picker ──────────────────────────────────────────
class _TaskGroupPicker extends StatelessWidget {
  const _TaskGroupPicker({
    required this.isDark,
    required this.taskGroups,
    required this.formGroupIds,
    required this.onAddTaskGroup,
    required this.onToggleTaskGroup,
    this.isRequired = false,
  });

  final bool isDark;
  final RxList<TaskGroup> taskGroups;
  final RxList<String> formGroupIds;
  final VoidCallback onAddTaskGroup;
  final void Function(String id) onToggleTaskGroup;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : kTextMuted,
                ),
                children: [
                  const TextSpan(text: 'Task Group'),
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onAddTaskGroup,
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 15, color: kPrimary),
                  const SizedBox(width: 4),
                  Text(
                    'New Task Group',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (taskGroups.isEmpty) {
            return GestureDetector(
              onTap: onAddTaskGroup,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimary.withAlpha(80), width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work_outline_rounded, size: 18, color: kPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No task groups yet. Tap here to create one first.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : kTextMuted,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: kPrimary,
                    ),
                  ],
                ),
              ),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: taskGroups.map((p) {
              final selected = formGroupIds.contains(p.id);
              return GestureDetector(
                onTap: () => onToggleTaskGroup(p.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? (p.color ?? kPrimary).withAlpha(40)
                        : (isDark ? kSurfaceDark : kBgLight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? (p.color ?? kPrimary)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? (p.color ?? kPrimary)
                          : (isDark ? Colors.grey[400] : kTextMuted),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
