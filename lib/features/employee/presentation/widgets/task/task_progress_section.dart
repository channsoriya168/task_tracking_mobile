import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_progress.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_progress_controller.dart';

// ── Progress section ──────────────────────────────────────────────────────────

class TaskProgressSection extends StatelessWidget {
  const TaskProgressSection({
    super.key,
    required this.ctrl,
    required this.taskId,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.canEdit,
  });

  final TaskProgressController ctrl;
  final String taskId;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progresses = ctrl.currentTaskProgresses.toList();
      final loading = ctrl.progressLoading.value;
      final error = ctrl.progressError.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Text('Progress',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const Spacer(),
              if (error.isNotEmpty && !loading) ...[
                GestureDetector(
                  onTap: () => ctrl.fetchTaskProgresses(taskId),
                  child: Icon(Icons.refresh_rounded,
                      size: 18,
                      color: Colors.red.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 8),
              ],
              if (canEdit)
                GestureDetector(
                  onTap: () => _showProgressSheet(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: kPrimary.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, size: 16, color: kPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (error.isNotEmpty && progresses.isEmpty)
            GestureDetector(
              onTap: () => ctrl.fetchTaskProgresses(taskId),
              child: Text(
                'Error: $error\n(Tap to retry)',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.withValues(alpha: 0.8)),
              ),
            )
          else if (progresses.isEmpty)
            Text('No progress logs yet.',
                style: TextStyle(fontSize: 13, color: mutedColor))
          else
            Column(
              children: progresses.asMap().entries.map((entry) {
                final isLast = entry.key == progresses.length - 1;
                return _ProgressItem(
                  progress: entry.value,
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  isLast: isLast,
                  canEdit: canEdit,
                  onEdit: () =>
                      _showProgressSheet(context, editing: entry.value),
                  onDelete: () => _confirmDelete(context, entry.value),
                );
              }).toList(),
            ),
        ],
      );
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, TaskProgress progress) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? kCardDark : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Progress',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : kTextDark)),
        content: Text('Remove this progress log?',
            style: TextStyle(color: isDark ? Colors.white70 : kTextMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white54 : kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await ctrl.deleteProgress(taskId, progress.id);
  }

  Future<void> _showProgressSheet(BuildContext context,
      {TaskProgress? editing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProgressSheet(
        taskId: taskId,
        ctrl: ctrl,
        isDark: isDark,
        editing: editing,
      ),
    );
  }
}

// ── Progress item ─────────────────────────────────────────────────────────────

class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.progress,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.isLast,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskProgress progress;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final bool isLast;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final pct = progress.progressPercentage;
    final barBg = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 70% content ─────────────────────────────────────────────
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notes (required, shown at top)
                Text(
                  progress.notes ?? '',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor),
                ),
                const SizedBox(height: 6),
                // Progress bar + percentage number
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0, 100) / 100,
                          minHeight: 6,
                          backgroundColor: barBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              kPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Time + hours
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: mutedColor),
                    const SizedBox(width: 3),
                    Text(
                      formatDate(progress.loggedAt ??
                          progress.createdAt ??
                          DateTime.now()),
                      style: TextStyle(fontSize: 11, color: mutedColor),
                    ),
                    if (progress.hoursWorked != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.hourglass_bottom_rounded,
                          size: 11, color: mutedColor),
                      const SizedBox(width: 3),
                      Text(
                        '${progress.hoursWorked!.toStringAsFixed(1)}h',
                        style: TextStyle(fontSize: 11, color: mutedColor),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // ── 30% actions dropdown ─────────────────────────────────────
          SizedBox(
            width: 36,
            child: canEdit
                ? PopupMenuButton<_ProgressAction>(
                    icon: Icon(Icons.more_vert_rounded,
                        size: 18, color: mutedColor),
                    color: isDark ? kCardDark : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.zero,
                    onSelected: (action) {
                      if (action == _ProgressAction.edit) onEdit();
                      if (action == _ProgressAction.delete) onDelete();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _ProgressAction.edit,
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 16, color: kPrimary),
                            const SizedBox(width: 8),
                            Text('Edit',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white
                                        : kTextDark)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _ProgressAction.delete,
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text('Delete',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

enum _ProgressAction { edit, delete }

// ── Add / Edit progress sheet ─────────────────────────────────────────────────

class _ProgressSheet extends StatefulWidget {
  const _ProgressSheet({
    required this.taskId,
    required this.ctrl,
    required this.isDark,
    this.editing,
  });

  final String taskId;
  final TaskProgressController ctrl;
  final bool isDark;
  /// Non-null when editing an existing record.
  final TaskProgress? editing;

  @override
  State<_ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<_ProgressSheet> {
  late final TextEditingController _pctCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _hoursCtrl;
  String? _notesError;
  bool _saving = false;

  bool get isEdit => widget.editing != null;
  bool get isDark => widget.isDark;
  Color get textColor => isDark ? Colors.white : kTextDark;
  Color get mutedColor => isDark ? Colors.white38 : kTextMuted;

  @override
  void initState() {
    super.initState();
    final p = widget.editing;
    _pctCtrl = TextEditingController(
        text: p != null ? '${p.progressPercentage}' : '0');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _hoursCtrl = TextEditingController(
        text: p?.hoursWorked != null
            ? p!.hoursWorked!.toStringAsFixed(1)
            : '');
  }

  @override
  void dispose() {
    _pctCtrl.dispose();
    _notesCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validate notes (required)
    final notes = _notesCtrl.text.trim();
    if (notes.isEmpty) {
      setState(() => _notesError = 'Notes are required');
      return;
    }
    setState(() => _notesError = null);

    // Percentage: default 0 if empty or invalid
    final pct = int.tryParse(_pctCtrl.text.trim()) ?? 0;
    final clampedPct = pct.clamp(0, 100);
    final hours = double.tryParse(_hoursCtrl.text.trim());

    setState(() => _saving = true);

    final bool ok;
    if (isEdit) {
      ok = await widget.ctrl.updateProgress(
        widget.taskId,
        widget.editing!.id,
        progressPercentage: clampedPct,
        loggedAt: widget.editing!.loggedAt ?? DateTime.now(),
        notes: notes,
        hoursWorked: hours,
      );
    } else {
      ok = await widget.ctrl.createProgress(
        widget.taskId,
        progressPercentage: clampedPct,
        loggedAt: DateTime.now(),
        notes: notes,
        hoursWorked: hours,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? kCardDark : Colors.white;
    final fieldFill = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    );

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(isEdit ? 'Edit Progress' : 'Log Progress',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            const SizedBox(height: 16),

            // Notes (required) — shown first
            Text('Notes *',
                style: TextStyle(fontSize: 13, color: mutedColor)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              style: TextStyle(color: textColor, fontSize: 14),
              maxLines: 3,
              onChanged: (_) {
                if (_notesError != null) {
                  setState(() => _notesError = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'What did you work on?',
                hintStyle: TextStyle(color: mutedColor),
                errorText: _notesError,
                filled: true,
                fillColor: fieldFill,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: border,
                enabledBorder: _notesError != null ? errorBorder : border,
                focusedBorder: _notesError != null ? errorBorder : border,
              ),
            ),
            const SizedBox(height: 12),

            // Percentage + Hours on one row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress % (0–100)',
                          style: TextStyle(fontSize: 13, color: mutedColor)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _pctCtrl,
                        style: TextStyle(color: textColor, fontSize: 14),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: mutedColor),
                          filled: true,
                          fillColor: fieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: border,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hours (optional)',
                          style: TextStyle(fontSize: 13, color: mutedColor)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _hoursCtrl,
                        style: TextStyle(color: textColor, fontSize: 14),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          hintText: 'e.g. 2.5',
                          hintStyle: TextStyle(color: mutedColor),
                          filled: true,
                          fillColor: fieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: border,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : Colors.black.withValues(alpha: 0.15)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancel',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mutedColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEdit ? 'Update' : 'Save',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
