import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/employee_controller.dart';
import 'package:task_tracking_mobile/features/manager/data/models/employee.dart';

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

// ── Add / Edit Employee Dialog ─────────────────────────────────
void showEmployeeDialog(
  BuildContext context,
  EmployeeController ctrl,
  bool isDark, [
  Employee? existing,
]) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final emailCtrl = TextEditingController(text: existing?.email ?? '');
  final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
  final imageCtrl = TextEditingController(text: existing?.imagePath ?? '');
  final imageUrl = (existing?.imagePath ?? '').obs;
  final placeCtrl = TextEditingController(text: existing?.placeOfBirth ?? '');
  final userIdCtrl = TextEditingController(text: existing?.userId ?? '');
  final selectedPositionId =
      (existing?.positionId ?? ctrl.positions.firstOrNull?.id ?? '').obs;
  final selectedDob = Rx<DateTime?>(existing?.dateOfBirth);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
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
            const SizedBox(height: 16),
            Text(
              existing == null ? 'Add Employee' : 'Edit Employee',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar preview ───────────────────────────
                    Center(
                      child: Obx(() {
                        final url = imageUrl.value;
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: kPrimary.withAlpha(40),
                          backgroundImage: url.isNotEmpty
                              ? NetworkImage(url)
                              : null,
                          child: url.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: kPrimary,
                                )
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    EmployeeDialogTextField(
                      controller: imageCtrl,
                      label: 'Profile Image URL',
                      hint: 'https://example.com/avatar.jpg',
                      isDark: isDark,
                      icon: Icons.image_outlined,
                      onChanged: (v) => imageUrl.value = v,
                    ),
                    const SizedBox(height: 14),
                    EmployeeDialogTextField(
                      controller: nameCtrl,
                      label: 'Full Name',
                      hint: 'e.g. Alice Johnson',
                      isDark: isDark,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    EmployeeDialogTextField(
                      controller: emailCtrl,
                      label: 'Email',
                      hint: 'e.g. alice@company.com',
                      isDark: isDark,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    EmployeeDialogTextField(
                      controller: phoneCtrl,
                      label: 'Phone',
                      hint: 'e.g. +855 12 345 678',
                      isDark: isDark,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    // ── Date of Birth ────────────────────────────
                    Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : kTextMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedDob.value ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) selectedDob.value = picked;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? kSurfaceDark : kBgLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cake_outlined,
                                size: 18,
                                color: isDark ? Colors.grey[500] : kTextMuted,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                selectedDob.value != null
                                    ? '${selectedDob.value!.day.toString().padLeft(2, '0')}/'
                                          '${selectedDob.value!.month.toString().padLeft(2, '0')}/'
                                          '${selectedDob.value!.year}'
                                    : 'Select date of birth',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selectedDob.value != null
                                      ? (isDark ? Colors.white : kTextDark)
                                      : (isDark
                                            ? Colors.grey[600]
                                            : Colors.grey[400]),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: isDark ? Colors.grey[500] : kTextMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    EmployeeDialogTextField(
                      controller: placeCtrl,
                      label: 'Place of Birth',
                      hint: 'e.g. Phnom Penh, Cambodia',
                      isDark: isDark,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),
                    EmployeeDialogTextField(
                      controller: userIdCtrl,
                      label: 'User Account ID',
                      hint: 'Link to user account (optional)',
                      isDark: isDark,
                      icon: Icons.account_circle_outlined,
                    ),
                    const SizedBox(height: 14),
                    // ── Position ─────────────────────────────────
                    Text(
                      'Position',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : kTextMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ctrl.positions.map((p) {
                          final selected = selectedPositionId.value == p.id;
                          return GestureDetector(
                            onTap: () => selectedPositionId.value = p.id,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? p.color.withAlpha(40)
                                    : (isDark ? kSurfaceDark : kBgLight),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? p.color
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                p.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? p.color
                                      : (isDark
                                            ? Colors.grey[400]
                                            : kTextMuted),
                                ),
                              ),
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
                          final email = emailCtrl.text.trim();
                          final posId = selectedPositionId.value;
                          if (name.isEmpty || email.isEmpty || posId.isEmpty) {
                            return;
                          }

                          if (existing == null) {
                            ctrl.addEmployee(
                              Employee(
                                id: ctrl.generateId(),
                                name: name,
                                email: email,
                                positionId: posId,
                                imagePath: imageCtrl.text.trim().isEmpty
                                    ? null
                                    : imageCtrl.text.trim(),
                                dateOfBirth: selectedDob.value,
                                placeOfBirth: placeCtrl.text.trim().isEmpty
                                    ? null
                                    : placeCtrl.text.trim(),
                                phone: phoneCtrl.text.trim().isEmpty
                                    ? null
                                    : phoneCtrl.text.trim(),
                                userId: userIdCtrl.text.trim().isEmpty
                                    ? null
                                    : userIdCtrl.text.trim(),
                              ),
                            );
                          } else {
                            ctrl.updateEmployee(
                              existing.copyWith(
                                name: name,
                                email: email,
                                positionId: posId,
                                imagePath: imageCtrl.text.trim().isEmpty
                                    ? null
                                    : imageCtrl.text.trim(),
                                dateOfBirth: selectedDob.value,
                                placeOfBirth: placeCtrl.text.trim().isEmpty
                                    ? null
                                    : placeCtrl.text.trim(),
                                phone: phoneCtrl.text.trim().isEmpty
                                    ? null
                                    : phoneCtrl.text.trim(),
                                userId: userIdCtrl.text.trim().isEmpty
                                    ? null
                                    : userIdCtrl.text.trim(),
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
                          existing == null ? 'Add Employee' : 'Save Changes',
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
          ],
        ),
      ),
    ),
  );
}

// ── Add / Edit Position Dialog ─────────────────────────────────
void showPositionDialog(
  BuildContext context,
  EmployeeController ctrl,
  bool isDark, [
  Position? existing,
]) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final selectedColor = (existing?.color ?? kPositionPresetColors.first).obs;

  showModalBottomSheet(
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

// ── Shared Dialog Text Field ───────────────────────────────────
class EmployeeDialogTextField extends StatelessWidget {
  const EmployeeDialogTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : kTextMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            color: isDark ? Colors.white : kTextDark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
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
      ],
    );
  }
}
