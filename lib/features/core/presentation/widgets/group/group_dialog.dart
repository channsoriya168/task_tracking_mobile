import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/group_controller.dart';

// ── Preset Colors ─────────────────────────────────────────────
const groupPresetColors = [
  Color(0xFF6C63FF),
  Color(0xFF2ED573),
  Color(0xFFFFA502),
  Color(0xFFFF4757),
  Color(0xFF1E90FF),
  Color(0xFFFF6B81),
  Color(0xFF5352ED),
  Color(0xFF26de81),
  Color(0xFFf7b731),
  Color(0xFFfc5c65),
  Color(0xFF45aaf2),
  Color(0xFFa55eea),
];

// ── Add / Edit Task Group Dialog ─────────────────────────────────
Future<void> showGroupDialog(
  BuildContext context,
  GroupController ctrl,
  bool isDark, [
  Group? existing,
]) async {
  ctrl.initGroupForm(existing);
  final showNameError = false.obs;
  final showColorError = false.obs;

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
              Row(
                children: [
                  Text(
                    existing == null
                        ? 'group_dialog_new'.tr
                        : 'group_dialog_edit'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Obx(
                () => TextFieldWidget(
                  controller: ctrl.nameEditingController,
                  label: 'group_name_label'.tr,
                  hint: 'group_name_hint'.tr,
                  isDark: isDark,
                  isRequired: true,
                  errorText: showNameError.value
                      ? 'group_name_required'.tr
                      : null,
                  onChanged: (_) {
                    if (showNameError.value &&
                        ctrl.nameEditingController.text.trim().isNotEmpty) {
                      showNameError.value = false;
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                controller: ctrl.descriptionEditingController,
                label: 'group_desc_label'.tr,
                hint: 'group_desc_hint'.tr,
                isDark: isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : kTextMuted,
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
                            if (showColorError.value) {
                              showColorError.value = false;
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
                    if (showColorError.value)
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
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ctrl.isSaving.value
                        ? null
                        : () async {
                            final name = ctrl.nameEditingController.text.trim();
                            final description = ctrl
                                .descriptionEditingController
                                .text
                                .trim();
                            final descriptionValue = description.isEmpty
                                ? null
                                : description;
                            final isNameValid = name.isNotEmpty;
                            final isColorValid =
                                ctrl.selectedColor.value != null;

                            showNameError.value = !isNameValid;
                            showColorError.value = !isColorValid;

                            if (!isNameValid || !isColorValid) return;

                            if (existing == null) {
                              final created = await ctrl.createGroup();
                              if (!created) return;
                            } else {
                              await ctrl.updateGroup(
                                existing.copyWith(
                                  id: existing.id,
                                  name: name,
                                  description: descriptionValue,
                                  color: ctrl.selectedColor.value!,
                                ),
                              );
                            }
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      disabledBackgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
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
                                ? 'group_btn_create'.tr
                                : 'group_btn_save'.tr,
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
