import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_picker_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_employee_form_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_task_group_controller.dart';

class AdminEmployeeFormDialog extends StatelessWidget {
  const AdminEmployeeFormDialog({super.key, required this.controller});

  final AdminEmployeeFormController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(right: 12),
                  ),
                  Expanded(
                    child: Text(
                      'Add Employee',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // ── Scrollable body ──────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ───────────────────────────────────────
                    Obx(() {
                      final img = controller.profileImage.value;
                      return Center(
                        child: GestureDetector(
                          onTap: controller.pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor:
                                    isDark ? Colors.grey[800] : Colors.grey[200],
                                backgroundImage: img != null
                                    ? FileImage(File(img.path))
                                    : null,
                                child: img == null
                                    ? Icon(Icons.person_rounded,
                                        size: 44,
                                        color: isDark
                                            ? Colors.grey[600]
                                            : Colors.grey[400])
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: kPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isDark ? kCardDark : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // ── Section: Basic Info ───────────────────────────
                    _SectionLabel(label: 'Basic Info', isDark: isDark),
                    const SizedBox(height: 12),
                    Obx(() => TextFieldWidget(
                          controller: controller.nameCtrl,
                          label: 'Full Name',
                          hint: 'e.g. Chan Sovann',
                          isDark: isDark,
                          isRequired: true,
                          prefixIcon: Icons.person_outline_rounded,
                          errorText: controller.fieldErrors['fullName'],
                        )),
                    const SizedBox(height: 12),
                    Obx(() => TextFieldWidget(
                          controller: controller.phoneCtrl,
                          label: 'Phone',
                          hint: 'e.g. +85512345678',
                          isDark: isDark,
                          keyboardType: TextInputType.phone,
                          isRequired: true,
                          prefixIcon: Icons.phone_outlined,
                          errorText: controller.fieldErrors['phone'],
                        )),
                    const SizedBox(height: 20),

                    // ── Section: Account ─────────────────────────────
                    _SectionLabel(label: 'Account', isDark: isDark),
                    const SizedBox(height: 12),
                    Obx(() => TextFieldWidget(
                          controller: controller.emailCtrl,
                          label: 'Email',
                          hint: 'e.g. chan@company.com',
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                          prefixIcon: Icons.email_outlined,
                          errorText: controller.fieldErrors['email'],
                        )),
                    const SizedBox(height: 12),
                    Obx(() => TextFieldWidget(
                          controller: controller.passwordCtrl,
                          label: 'Password',
                          hint: 'e.g. MyPass@123',
                          isDark: isDark,
                          isRequired: true,
                          obscureText: !controller.showPassword.value,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showPassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                            onPressed: () => controller.showPassword.toggle(),
                          ),
                          errorText: controller.fieldErrors['password'],
                        )),
                    const SizedBox(height: 12),
                    Obx(() => TextFieldWidget(
                          controller: controller.confirmPasswordCtrl,
                          label: 'Confirm Password',
                          hint: 'Re-enter password',
                          isDark: isDark,
                          isRequired: true,
                          obscureText: !controller.showConfirmPassword.value,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showConfirmPassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                            onPressed: () => controller.showConfirmPassword.toggle(),
                          ),
                          errorText: controller.fieldErrors['confirmPassword'],
                        )),
                    const SizedBox(height: 20),

                    // ── Section: Personal Details ─────────────────────
                    _SectionLabel(label: 'Personal Details', isDark: isDark),
                    const SizedBox(height: 12),
                    DatePickerWidget(
                      isDark: isDark,
                      value: controller.formDob,
                      onPicked: (d) => controller.formDob.value = d,
                      label: 'Date of Birth',
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: controller.placeCtrl,
                      label: 'Place of Birth',
                      hint: 'e.g. Phnom Penh',
                      isDark: isDark,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ── Section: Assignment ───────────────────────────
                    _GroupPicker(controller: controller, isDark: isDark),
                    const SizedBox(height: 28),

                    // ── Save button ───────────────────────────────────
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  kPrimary.withValues(alpha: 0.5),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Add Employee',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        )),
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

// ── Section label ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});

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
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(
            thickness: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
        ),
      ],
    );
  }
}

// ── Group picker ───────────────────────────────────────────────────────────────
class _GroupPicker extends StatelessWidget {
  const _GroupPicker({required this.controller, required this.isDark});

  final AdminEmployeeFormController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tgCtrl = Get.find<AdminTaskGroupController>();
    return Obx(() {
      final groups = tgCtrl.taskGroups;
      if (groups.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Assignment', isDark: isDark),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: groups.map((g) {
              final selected = controller.selectedGroupIds.contains(g.id);
              final color = g.color ?? kPrimary;
              return GestureDetector(
                onTap: () => controller.toggleGroup(g.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? color : color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? color
                          : color.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    g.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
