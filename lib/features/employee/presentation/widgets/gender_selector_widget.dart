import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_controller.dart';

class GenderSelectorWidget extends StatelessWidget {
  const GenderSelectorWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

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
