import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_label_controller.dart';

Future<void> showAdminLabelDialog(
  BuildContext context,
  AdminLabelController ctrl,
  bool isDark,
) async {
  ctrl.initForm();

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
            Text(
              'New Label',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 20),
            // Name field
            Obx(
              () => TextFieldWidget(
                controller: ctrl.nameCtrl,
                label: 'Label Name',
                hint: 'e.g. Urgent',
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
              label: 'Description',
              hint: 'Short notes about this label',
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
                          final success = await ctrl.createLabel();
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
                      : const Text(
                          'Create Label',
                          style: TextStyle(
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
  );
}
