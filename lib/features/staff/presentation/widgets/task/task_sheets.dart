import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

void showTaskSheet(
  BuildContext context,
  TaskController ctrl,
  TaskModel? existing,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final category = (existing?.category ?? 'General').obs;

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(isDark),
              const SizedBox(height: 20),
              Text(
                existing == null ? 'New Task' : 'Edit Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              _taskField(titleCtrl, 'Title', isDark),
              const SizedBox(height: 12),
              _taskField(
                descCtrl,
                'Description (optional)',
                isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontSize: 13, color: kTextMuted),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: category.value,
                items: kCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) category.value = v;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? kCardDark : kBgLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: kContentPaddingSmall,
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : kTextDark,
                ),
                dropdownColor: isDark ? kCardDark : Colors.white,
              ),
              const SizedBox(height: 24),
              _submitButton(
                label: existing == null ? 'Add Task' : 'Save Changes',
                color: kPrimary,
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  if (existing == null) {
                    ctrl.addTask(
                      TaskModel(
                        id: ctrl.generateId(),
                        title: title,
                        description: descCtrl.text.trim(),
                        category: category.value,
                      ),
                    );
                  } else {
                    ctrl.updateTask(
                      existing.copyWith(
                        title: title,
                        description: descCtrl.text.trim(),
                        category: category.value,
                      ),
                    );
                  }
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

void showProgressSheet(
  BuildContext context,
  TaskController ctrl,
  TaskModel task,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final descCtrl = TextEditingController(text: task.description);
  final isAccept = task.status == TaskStatus.todo;

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(isDark),
            const SizedBox(height: 20),
            Text(
              isAccept ? 'Accept Task' : 'Submit Task',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Title',
              style: TextStyle(fontSize: 13, color: kTextMuted),
            ),
            const SizedBox(height: 6),
            _readonlyField(task.title, isDark),
            const SizedBox(height: 12),
            const Text(
              'Category',
              style: TextStyle(fontSize: 13, color: kTextMuted),
            ),
            const SizedBox(height: 6),
            _readonlyField(task.category, isDark, muted: true),
            const SizedBox(height: 12),
            const Text(
              'Progress Notes',
              style: TextStyle(fontSize: 13, color: kTextMuted),
            ),
            const SizedBox(height: 6),
            _taskField(descCtrl, 'Describe your progress...', isDark, maxLines: 3),
            const SizedBox(height: 24),
            _submitButton(
              label: isAccept ? 'Accept Task' : 'Submit Task',
              color: isAccept ? kPrimary : const Color(0xFF4CAF50),
              onPressed: () {
                final desc = descCtrl.text.trim();
                if (isAccept) {
                  ctrl.acceptTask(task.id, description: desc);
                } else {
                  ctrl.finishTask(task.id, description: desc);
                }
                Get.back();
              },
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

// ── Private helpers ────────────────────────────────────────────

Widget _sheetHandle(bool isDark) {
  return Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Widget _readonlyField(String text, bool isDark, {bool muted = false}) {
  return Container(
    width: double.infinity,
    padding: kContentPaddingSmall,
    decoration: BoxDecoration(
      color: isDark ? kCardDark : kBgLight,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: muted ? FontWeight.normal : FontWeight.w500,
        color: muted ? kTextMuted : (isDark ? Colors.white : kTextDark),
      ),
    ),
  );
}

Widget _taskField(
  TextEditingController ctrl,
  String hint,
  bool isDark, {
  int maxLines = 1,
}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : kTextDark),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
      filled: true,
      fillColor: isDark ? kCardDark : kBgLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: kContentPaddingSmall,
    ),
  );
}

Widget _submitButton({
  required String label,
  required Color color,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
