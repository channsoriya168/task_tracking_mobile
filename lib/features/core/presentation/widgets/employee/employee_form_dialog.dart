import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/enums/user_role.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_picker_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/password_input_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_form_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/employee_form_group_picker.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/employee/phone_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/field_label_widget.dart';

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
            // ── Drag handle (always at very top) ─────────────────
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Header ───────────────────────────────────────────
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        controller.isEditMode.value
                            ? Icons.edit_rounded
                            : Icons.person_add_rounded,
                        color: kPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.isEditMode.value
                                ? 'Edit Employee'
                                : 'Add Employee',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : kTextDark,
                            ),
                          ),
                          Text(
                            controller.isEditMode.value
                                ? 'Update employee information'
                                : 'Fill in the details below',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[500] : kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(
              height: 24,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),

            // ── Scrollable body ──────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ───────────────────────────────────
                    EmployeeFormAvatar(controller: controller, isDark: isDark),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextFieldWidget(
                        controller: controller.nameCtrl,
                        label: 'Full Name',
                        hint: 'e.g. Sok Dara',
                        isDark: isDark,
                        isRequired: true,
                        errorText: controller.fieldErrors['fullName'],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => PhoneFieldWidget(
                        controller: controller.phoneCtrl,
                        isDark: isDark,
                        errorText: controller.fieldErrors['phone'],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => TextFieldWidget(
                        controller: controller.emailCtrl,
                        label: 'Email',
                        hint: 'e.g. sokdara@company.com',
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,
                        errorText: controller.fieldErrors['email'],
                      ),
                    ),
                    // Password fields — required on create, optional on edit
                    Obx(
                      () => controller.isEditMode.value
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Obx(
                                  () => PasswordInputWidget(
                                    controller: controller.passwordCtrl,
                                    label: 'Password',
                                    hint: 'Enter a strong password',
                                    isDark: isDark,
                                    isRequired: true,
                                    errorText:
                                        controller.fieldErrors['password'],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Obx(
                                  () => PasswordInputWidget(
                                    controller: controller.confirmPasswordCtrl,
                                    label: 'Confirm Password',
                                    hint: 'Re-enter password',
                                    isDark: isDark,
                                    isRequired: true,
                                    errorText: controller
                                        .fieldErrors['confirmPassword'],
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 12),
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
                    ),
                    _RoleSelector(controller: controller, isDark: isDark),
                    const SizedBox(height: 24),

                    // ── Assignment ────────────────────────────────
                    EmployeeFormGroupPicker(
                      controller: controller,
                      isDark: isDark,
                    ),
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
                              alpha: 0.4,
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

// ── Role selector (Admin only) ──────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.controller, required this.isDark});

  final EmployeeController controller;
  final bool isDark;

  static const _roles = ['Employee', 'Manager'];

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    // Manager users cannot assign roles — role is always "Employee"
    if (authCtrl.role != UserRole.Admin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        FieldLabelWidget('Role', isDark: isDark, isRequired: true),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: _roles.map((role) {
              final isSelected = controller.selectedRole.value == role;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => controller.selectedRole.value = role,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimary.withValues(alpha: 0.12)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? kPrimary
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.grey[300]!),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: kPrimary,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? kPrimary
                                : (isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
