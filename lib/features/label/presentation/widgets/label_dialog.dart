import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/label/domain/entities/label.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/label/presentation/controllers/label_controller.dart';

Future<void> showLabelDialog(
  BuildContext context,
  LabelController ctrl,
  bool isDark, [
  Label? existing,
]) async {
  ctrl.initForm(existing);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Handle
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  existing == null ? 'label_new'.tr : 'label_edit'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.grey[400] : kTextMuted,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Name field
            Obx(
              () => TextFieldWidget(
                controller: ctrl.nameCtrl,
                label: 'label_name'.tr,
                hint: 'label_name_hint'.tr,
                isDark: isDark,
                isRequired: true,
                errorText: ctrl.nameError.value.isEmpty
                    ? null
                    : ctrl.nameError.value,
                onChanged: (_) {
                  if (ctrl.nameError.value.isNotEmpty &&
                      ctrl.nameCtrl.text.trim().isNotEmpty) {
                    ctrl.nameError.value = '';
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            // Description field
            TextFieldWidget(
              controller: ctrl.descriptionCtrl,
              label: 'label_description'.tr,
              hint: 'label_description_hint'.tr,
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Save button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.isSaving.value
                      ? null
                      : () async {
                          final nav = Navigator.of(context);
                          final success = existing == null
                              ? await ctrl.createLabel()
                              : await ctrl.updateLabel(existing.id);
                          if (success) nav.pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kPrimary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: ctrl.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          existing == null
                              ? 'label_create_btn'.tr
                              : 'label_save_btn'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    ),
  );
}
