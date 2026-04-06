import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/group.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/group_controller.dart';

// ── Preset Colors ──────────────────────────────────────────────────────────────
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

// ── Add / Edit Task Group Sheet ────────────────────────────────────────────────
Future<void> showGroupDialog(
  BuildContext context,
  GroupController ctrl,
  bool isDark, [
  Group? existing,
]) async {
  ctrl.initGroupForm(existing);
  final showNameError = false.obs;
  final showColorError = false.obs;
  final nameText = ctrl.nameEditingController.text.obs;

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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing == null
                            ? 'group_dialog_new'.tr
                            : 'group_dialog_edit'.tr,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
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
                        errorText: showNameError.value
                            ? 'group_name_required'.tr
                            : null,
                        onChanged: (v) {
                          nameText.value = v;
                          if (showNameError.value && v.trim().isNotEmpty) {
                            showNameError.value = false;
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
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Footer: Cancel + Save ─────────────────────────────
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
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: ctrl.isSaving.value
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                        child: Text(
                          'dialog_cancel'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed:
                            ctrl.isSaving.value || nameText.value.trim().isEmpty
                            ? null
                            : () async {
                                final name = ctrl.nameEditingController.text
                                    .trim();
                                final description = ctrl
                                    .descriptionEditingController
                                    .text
                                    .trim();
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
                                      description: description.isEmpty
                                          ? null
                                          : description,
                                      color: ctrl.selectedColor.value!,
                                    ),
                                  );
                                }
                                Navigator.pop(context);
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
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
}
