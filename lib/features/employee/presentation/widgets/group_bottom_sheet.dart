import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_dialog.dart';

class GroupBottomSheet extends StatelessWidget {
  const GroupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GroupController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 4, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'group_dialog_new'.tr,
                    style: AppTextStyles.appBarTitle(color: kPrimary),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable body ───────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => TextFieldWidget(
                      controller: ctrl.nameEditingController,
                      label: 'group_name_label'.tr,
                      hint: 'group_name_hint'.tr,
                      isDark: isDark,
                      isRequired: true,
                      errorText: ctrl.showNameError.value
                          ? 'group_name_required'.tr
                          : null,
                      onChanged: (v) {
                        if (ctrl.showNameError.value && v.trim().isNotEmpty) {
                          ctrl.showNameError.value = false;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: ctrl.descriptionEditingController,
                    label: 'group_desc_label'.tr,
                    hint: 'group_desc_hint'.tr,
                    isDark: isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.formLabel(
                        color: isDark ? Colors.grey[300] : kBgDark,
                      ),
                      children: [
                        TextSpan(text: 'group_color_label'.tr),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: groupPresetColors.map((color) {
                            final selected =
                                ctrl.selectedColor.value?.toARGB32() ==
                                color.toARGB32();
                            return GestureDetector(
                              onTap: () {
                                ctrl.selectedColor.value = color;
                                if (ctrl.showColorError.value) {
                                  ctrl.showColorError.value = false;
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? (isDark ? Colors.white : kTextDark)
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: color.withAlpha(100),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        if (ctrl.showColorError.value)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'group_color_required'.tr,
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Footer: Save ──────────────────────────────────────
          Obx(() {
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ctrl.isSaving.value
                          ? null
                          : () async {
                              final name = ctrl.nameEditingController.text
                                  .trim();
                              final isColorValid =
                                  ctrl.selectedColor.value != null;

                              ctrl.showNameError.value = name.isEmpty;
                              ctrl.showColorError.value = !isColorValid;
                              if (name.isEmpty || !isColorValid) return;

                              final created = await ctrl.createGroup();
                              if (created && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: kPrimary.withValues(
                          alpha: 0.4,
                        ),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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
                              'group_btn_create'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
