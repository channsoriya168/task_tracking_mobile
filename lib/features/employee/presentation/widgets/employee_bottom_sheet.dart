import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/date_picker_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_form_avatar_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/employee_form_group_picker.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/gender_selector_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/phone_field_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/role_selector_widget.dart';

class EmployeeBottomSheet extends StatelessWidget {
  const EmployeeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const _gap = SizedBox(height: 16);
    const _gapSm = SizedBox(height: 12);
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
                    GenderSelectorWidget(
                      controller: controller,
                      isDark: isDark,
                    ),

                    // ── Section: Role (admin only) ───────────────
                    _gap,
                    RoleSelectorWidget(controller: controller, isDark: isDark),

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
      child: ListenableBuilder(
        listenable: Listenable.merge([
          controller.nameCtrl,
          controller.phoneCtrl,
        ]),
        builder: (context, _) {
          return Obx(() {
            final canSave =
                controller.nameCtrl.text.trim().isNotEmpty &&
                controller.phoneCtrl.text.trim().isNotEmpty &&
                controller.formDob.value != null &&
                controller.selectedRole.value.isNotEmpty &&
                controller.selectedGenderId.value != null &&
                controller.selectedGroupId.value != null;
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: canSave && !controller.isSaving.value
                        ? controller.save
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kPrimary.withValues(alpha: 0.4),
                      disabledForegroundColor: Colors.white,
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
                            style: AppTextStyles.buttonLabel(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
