import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_picker_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';

class ManagerEmployeeFormDialog extends StatelessWidget {
  const ManagerEmployeeFormDialog({super.key, required this.controller});

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
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────────
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.isEditMode.value
                            ? 'Edit Employee'
                            : 'Add Employee',
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
            ),
            // Drag handle
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

            // ── Scrollable body ──────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ───────────────────────────────────
                    Obx(() {
                      final img = controller.profileImage.value;
                      final existingUrl = controller.existingImageUrl;
                      final removed = controller.removeProfileImage.value;
                      ImageProvider? bgImage;
                      if (img != null) {
                        bgImage = FileImage(File(img.path));
                      } else if (!removed &&
                          existingUrl != null &&
                          existingUrl.isNotEmpty) {
                        bgImage = NetworkImage(existingUrl);
                      }
                      return Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: controller.pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                    backgroundImage: bgImage,
                                    child: bgImage == null
                                        ? Icon(
                                            Icons.person_rounded,
                                            size: 44,
                                            color: isDark
                                                ? Colors.grey[600]
                                                : Colors.grey[400],
                                          )
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
                                          color: isDark
                                              ? kCardDark
                                              : Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.isEditMode.value &&
                                bgImage != null) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  controller.profileImage.value = null;
                                  controller.removeProfileImage.value = true;
                                },
                                child: Text(
                                  'Remove photo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kHighPriority,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextFieldWidget(
                        controller: controller.nameCtrl,
                        label: 'Full Name',
                        hint: 'e.g. Chan Sovann',
                        isDark: isDark,
                        isRequired: true,
                        prefixIcon: Icons.person_outline_rounded,
                        errorText: controller.fieldErrors['fullName'],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextFieldWidget(
                        controller: controller.phoneCtrl,
                        label: 'Phone',
                        hint: 'e.g. 0884311016',
                        isDark: isDark,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        prefixIcon: Icons.phone_outlined,
                        errorText: controller.fieldErrors['phone'],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextFieldWidget(
                        controller: controller.emailCtrl,
                        label: 'Email',
                        hint: 'e.g. chan@company.com',
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,

                        prefixIcon: Icons.email_outlined,
                        errorText: controller.fieldErrors['email'],
                      ),
                    ),
                    Obx(
                      () => controller.isEditMode.value
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                const SizedBox(height: 12),
                                Obx(
                                  () => TextFieldWidget(
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
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 18,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: () =>
                                          controller.showPassword.toggle(),
                                    ),
                                    errorText:
                                        controller.fieldErrors['password'],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Obx(
                                  () => TextFieldWidget(
                                    controller: controller.confirmPasswordCtrl,
                                    label: 'Confirm Password',
                                    hint: 'Re-enter password',
                                    isDark: isDark,
                                    isRequired: true,
                                    obscureText:
                                        !controller.showConfirmPassword.value,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.showConfirmPassword.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 18,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: () => controller
                                          .showConfirmPassword
                                          .toggle(),
                                    ),
                                    errorText: controller
                                        .fieldErrors['confirmPassword'],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => DatePickerWidget(
                        isDark: isDark,
                        value: controller.formDob,
                        onPicked: (d) {
                          controller.formDob.value = d;
                          controller.fieldErrors.remove('dob');
                        },
                        label: 'Date of Birth',
                        isRequired: true,
                        errorText: controller.fieldErrors['dob'],
                      ),
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

                    // ── Assignment ────────────────────────────────
                    _GroupPicker(controller: controller, isDark: isDark),
                    Obx(() {
                      final err = controller.fieldErrors['taskGroup'];
                      if (err == null || err.isEmpty)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          err,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 28),

                    // ── Save button ───────────────────────────────
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.isSaving.value || !controller.canSave
                              ? null
                              : controller.save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: kPrimary.withValues(
                              alpha: 0.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                              : Obx(
                                  () => Text(
                                    controller.isEditMode.value
                                        ? 'Save Changes'
                                        : 'Add Employee',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
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

// ── Section label ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.isDark,
    this.isRequired = false,
  });

  final String label;
  final bool isDark;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.grey[500],
            ),
            children: [
              TextSpan(text: label.toUpperCase()),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
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

// ── Group picker (single select) ───────────────────────────────
class _GroupPicker extends StatelessWidget {
  const _GroupPicker({required this.controller, required this.isDark});

  final EmployeeController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tgCtrl = Get.find<TaskGroupController>();
    return Obx(() {
      final groups = tgCtrl.taskGroups.cast<TaskGroup>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row — wrap _SectionLabel in Expanded to prevent layout error
          Row(
            children: [
              Expanded(
                child: _SectionLabel(
                  label: 'Assignment',
                  isDark: isDark,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => controller.openTaskGroupDialog(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 15, color: kPrimary),
                    const SizedBox(width: 3),
                    Text(
                      'New',
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
          const SizedBox(height: 12),
          if (groups.isEmpty)
            GestureDetector(
              onTap: () => controller.openTaskGroupDialog(context),
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
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: groups.map((g) {
                final selected = controller.selectedGroupId.value == g.id;
                final color = g.color ?? kPrimary;
                return GestureDetector(
                  onTap: () => controller.selectGroup(g.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? color : color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? color : color.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          g.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : color,
                          ),
                        ),
                      ],
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
