import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/position_controller.dart';

// ── Preset Colors ─────────────────────────────────────────────
const kPositionPresetColors = [
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

// ── Add / Edit Position Dialog ─────────────────────────────────
Future<void> showPositionDialog(
  BuildContext context,
  PositionController ctrl,
  bool isDark, [
  Position? existing,
]) async {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final selectedColor = (existing?.color ?? kPositionPresetColors.first).obs;

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
              existing == null ? 'New Position' : 'Edit Position',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Position Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : kTextMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              style: TextStyle(
                color: isDark ? Colors.white : kTextDark,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Engineering',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.work_outline_rounded,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                  size: 18,
                ),
                filled: true,
                fillColor: isDark ? kSurfaceDark : kBgLight,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Color',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : kTextMuted,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kPositionPresetColors.map((color) {
                  final selected = selectedColor.value == color;
                  return GestureDetector(
                    onTap: () => selectedColor.value = color,
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
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;

                  if (existing == null) {
                    ctrl.addPosition(
                      Position(
                        id: ctrl.generateId(),
                        name: name,
                        color: selectedColor.value,
                      ),
                    );
                  } else {
                    ctrl.updatePosition(
                      existing.copyWith(name: name, color: selectedColor.value),
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
                  existing == null ? 'Create Position' : 'Save Changes',
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
  );
}