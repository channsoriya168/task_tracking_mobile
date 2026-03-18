import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_group.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';

// ── Preset Colors ─────────────────────────────────────────────
const taskGroupPresetColors = [
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
Future<void> showTaskGroupDialog(
  BuildContext context,
  TaskGroupController ctrl,
  bool isDark, [
  TaskGroup? existing,
]) async {
  ctrl.initTaskGroupForm(existing);
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
            const SizedBox(height: 20),
            Text(
              existing == null ? 'New Task Group' : 'Edit Task Group',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => TextFieldWidget(
                controller: ctrl.nameEditingController,
                label: 'Task Group Name',
                hint: 'e.g. Engineering',
                isDark: isDark,
                isRequired: true,
                errorText: showNameError.value
                    ? 'Task group name is required'
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
              label: 'Description',
              hint: 'Short notes about this position',
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
                children: const [
                  TextSpan(text: 'Color'),
                  TextSpan(
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
                    children: taskGroupPresetColors.map((color) {
                      final selected = ctrl.selectedColor.value == color;
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
                        'Color is required',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final name = ctrl.nameEditingController.text.trim();
                  final description = ctrl.descriptionEditingController.text
                      .trim();
                  final descriptionValue = description.isEmpty
                      ? null
                      : description;
                  final isNameValid = name.isNotEmpty;
                  final isColorValid = ctrl.selectedColor.value != null;

                  showNameError.value = !isNameValid;
                  showColorError.value = !isColorValid;

                  if (!isNameValid || !isColorValid) return;

                  if (existing == null) {
                    final created = await ctrl.createTaskGroup(
                      name: name,
                      color: ctrl.selectedColor.value!,
                      description: descriptionValue,
                    );
                    if (!created) return;
                  } else {
                    ctrl.updateTaskGroup(
                      existing.copyWith(
                        name: name,
                        color: ctrl.selectedColor.value!,
                        description: descriptionValue,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  existing == null ? 'Create Task Group' : 'Save Changes',
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
      ),
    ),
  );
}
