import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_picker_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/password_input_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_form_avatar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_form_group_picker.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/phone_field_widget.dart';

const _gap = SizedBox(height: 16);
const _gapSm = SizedBox(height: 12);

class EmployeeFormDialog extends StatelessWidget {
  const EmployeeFormDialog({super.key, required this.controller});

  final EmployeeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
            //start header
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.isEditMode.value
                                ? 'emp_form_title_edit'.tr
                                : 'emp_form_title_add'.tr,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : kTextDark,
                            ),
                          ),
                          Text(
                            controller.isEditMode.value
                                ? 'emp_form_subtitle_edit'.tr
                                : 'emp_form_subtitle_add'.tr,
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
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // end header
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ───────────────────────────────────
                    Center(
                      child: EmployeeFormAvatar(
                        controller: controller,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _gapSm,
                    Obx(
                      () => TextFieldWidget(
                        controller: controller.nameCtrl,
                        label: 'profile_full_name'.tr,
                        hint: 'emp_form_name_hint'.tr,
                        isDark: isDark,
                        isRequired: true,
                        errorText: controller.fieldErrors['fullName'],
                      ),
                    ),
                    _gap,
                    Obx(
                      () => PhoneFieldWidget(
                        controller: controller.phoneCtrl,
                        isDark: isDark,
                        errorText: controller.fieldErrors['phone'],
                      ),
                    ),
                    _gap,
                    Obx(
                      () => TextFieldWidget(
                        controller: controller.emailCtrl,
                        label: 'profile_email'.tr,
                        hint: 'emp_form_email_hint'.tr,
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,
                        errorText: controller.fieldErrors['email'],
                      ),
                    ),
                    _gap,
                    Obx(
                      () => DatePickerWidget(
                        isDark: isDark,
                        value: controller.formDob,
                        onPicked: (d) {
                          controller.formDob.value = d;
                          controller.fieldErrors.remove('dob');
                        },
                        label: 'profile_date_of_birth'.tr,
                        isRequired: true,
                        errorText: controller.fieldErrors['dob'],
                      ),
                    ),
                    _gap,
                    TextFieldWidget(
                      controller: controller.placeCtrl,
                      label: 'profile_place_of_birth'.tr,
                      hint: 'emp_form_place_hint'.tr,
                      isDark: isDark,
                    ),
                    _gap,
                    _GenderSelector(controller: controller, isDark: isDark),

                    // ── Section: Account ─────────────────────────
                    Obx(() {
                      if (controller.isEditMode.value) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _gapSm,
                          Obx(
                            () => PasswordInputWidget(
                              controller: controller.passwordCtrl,
                              label: 'login_password_label'.tr,
                              hint: 'emp_form_password_hint'.tr,
                              isDark: isDark,
                              isRequired: true,
                              errorText: controller.fieldErrors['password'],
                              helperText:
                                  controller.fieldErrors['password'] == null
                                  ? 'emp_form_password_helper'.tr
                                  : null,
                            ),
                          ),
                          _gap,
                          Obx(
                            () => PasswordInputWidget(
                              controller: controller.confirmPasswordCtrl,
                              label: 'emp_form_confirm_password_label'.tr,
                              hint: 'emp_form_confirm_password_hint'.tr,
                              isDark: isDark,
                              isRequired: true,
                              errorText:
                                  controller.fieldErrors['confirmPassword'],
                            ),
                          ),
                        ],
                      );
                    }),

                    // ── Section: Role (admin only) ───────────────
                    _RoleSelector(controller: controller, isDark: isDark),

                    _gapSm,
                    EmployeeFormGroupPicker(
                      controller: controller,
                      isDark: isDark,
                    ),
                    Obx(() {
                      final err = controller.fieldErrors['taskGroup'];
                      if (err == null || err.isEmpty) {
                        return const SizedBox.shrink();
                      }
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
                  ],
                ),
              ),
            ),

            // ── Footer: Cancel + Save ────────────────────────────
            _Footer(controller: controller, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ── Footer ─────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.controller, required this.isDark});

  final EmployeeController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            // Save
            Expanded(
              child: ElevatedButton(
                onPressed: controller.isSaving.value || !controller.canSave
                    ? null
                    : controller.save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kPrimary.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                    : Text(
                        controller.isEditMode.value
                            ? 'emp_form_btn_save'.tr
                            : 'emp_form_btn_add'.tr,
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
    );
  }
}

// ── Gender selector ────────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.controller, required this.isDark});

  final EmployeeController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final genders = controller.genders;
      if (genders.isEmpty) return const SizedBox.shrink();

      final selected = controller.selectedGenderId.value;
      final errorText = controller.fieldErrors['gender'];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : kTextMuted,
              ),
              children: [
                TextSpan(text: 'emp_form_gender_label'.tr),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'emp_form_gender_hint'.tr,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                fontSize: 14,
              ),
              errorText: errorText,
              filled: true,
              fillColor: isDark ? kSurfaceDark : kBgLight,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: errorText != null
                      ? Colors.red
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : kPrimary,
                  width: 1.5,
                ),
              ),
            ),
            dropdownColor: isDark ? kCardDark : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : kTextDark,
              fontSize: 14,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
            //padding
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'emp_form_gender_hint'.tr,
                  style: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
              ...genders.map(
                (g) =>
                    DropdownMenuItem<String>(value: g.id, child: Text(g.name)),
              ),
            ],
            onChanged: (value) {
              controller.selectedGenderId.value = value;
              if (value != null) controller.fieldErrors.remove('gender');
            },
          ),
        ],
      );
    });
  }
}

// ── Role selector (Admin only) ─────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.controller, required this.isDark});

  final EmployeeController controller;
  final bool isDark;

  static const _roles = ['Employee', 'Manager'];

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    if (authCtrl.role != UserRole.admin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
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
