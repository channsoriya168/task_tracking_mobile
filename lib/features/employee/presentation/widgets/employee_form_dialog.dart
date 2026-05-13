import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_picker_widget.dart';
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
                            style: AppTextStyles.appBarTitle(color: kPrimary),
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

                    // ── Section: Role (admin only) ───────────────
                    _gap,
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
                          style: AppTextStyles.errorText(color: Colors.red),
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
                        style: AppTextStyles.buttonLabel(color: Colors.white),
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

  static String _label(String name) =>
      name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ');

  void _showPicker(BuildContext context) {
    final genders = controller.genders;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'emp_form_gender_label'.tr,
                  style: AppTextStyles.formLabel(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ),
            ),
            ...genders.map((g) {
              return Obx(
                () => InkWell(
                  onTap: () {
                    controller.selectedGenderId.value = g.id;
                    controller.fieldErrors.remove('gender');
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _label(g.name),
                            style: AppTextStyles.inputText(
                              color: (controller.selectedGenderId.value == g.id)
                                  ? kPrimary
                                  : (isDark ? Colors.white : kTextDark),
                            ),
                          ),
                        ),
                        if (controller.selectedGenderId.value == g.id)
                          Icon(Icons.check_rounded, size: 18, color: kPrimary),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final genders = controller.genders;
      if (genders.isEmpty) return const SizedBox.shrink();

      final selected = controller.selectedGenderId.value;
      final errorText = controller.fieldErrors['gender'];
      final selectedGender = selected != null
          ? genders.firstWhereOrNull((g) => g.id == selected)
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.formLabel(
                color: isDark ? Colors.white : kTextDark,
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
          GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isDark ? kSurfaceDark : kBgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: errorText != null
                      ? Colors.red
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  width: errorText != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedGender != null
                          ? _label(selectedGender.name)
                          : 'emp_form_gender_hint'.tr,
                      style: AppTextStyles.inputText(
                        color: selectedGender != null
                            ? (isDark ? Colors.white : kTextDark)
                            : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                errorText,
                style: AppTextStyles.errorText(color: Colors.red),
              ),
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
        RichText(
          text: TextSpan(
            style: AppTextStyles.formLabel(
              color: isDark ? Colors.white : kTextDark,
            ),
            children: [
              TextSpan(text: 'emp_form_role_label'.tr),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
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
                          style: AppTextStyles.chipLabel(
                            selected: isSelected,
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
