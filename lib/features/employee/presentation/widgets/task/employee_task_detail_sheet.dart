import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_picker_sheet.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_members_section.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_progress_section.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_sheet_widgets.dart';

Future<void> showEmployeeTaskDetailSheet(
  BuildContext context,
  bool isDark,
  TaskItem task, {
  bool showMembers = false,
  bool showProgress = false,
  bool readOnly = false,
}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskDetailSheet(
        task: task,
        isDark: isDark,
        showMembers: showMembers,
        showProgress: showProgress,
        readOnly: readOnly,
      ),
    );

// ── Sheet widget ──────────────────────────────────────────────────────────────

class _TaskDetailSheet extends StatelessWidget {
  const _TaskDetailSheet({
    required this.task,
    required this.isDark,
    required this.showMembers,
    required this.showProgress,
    required this.readOnly,
  });

  final TaskItem task;
  final bool isDark;
  final bool showMembers;
  final bool showProgress;
  final bool readOnly;

  EmployeeTaskController get ctrl => Get.find<EmployeeTaskController>();

  Color get textColor => isDark ? Colors.white : kTextDark;
  Color get mutedColor => isDark ? Colors.white38 : kTextMuted;
  Color get divColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    Color confirmColor = kPrimary,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: isDark ? kCardDark : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : kTextDark),
          ),
          content: Text(
            content,
            style: TextStyle(color: isDark ? Colors.white70 : kTextMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.white54 : kTextMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );

  // ── Member actions ────────────────────────────────────────────────────────

  Future<void> _onAddMember(
      BuildContext context, List<TaskMember> currentMembers) async {
    if (ctrl.groupEmployees.isEmpty) await ctrl.fetchGroupEmployees();

    final addedIds = currentMembers.map((m) => m.employeeId).toSet();
    final available = ctrl.groupEmployees
        .where((e) => !addedIds.contains(e.id) && e.id != ctrl.currentEmployeeId)
        .toList();

    if (!context.mounted) return;

    final selected = await showModalBottomSheet<Employee>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          EmployeePickerSheet(employees: available, isDark: isDark),
    );
    if (selected == null || !context.mounted) return;

    final ok = await _confirm(
      context,
      title: 'Add Member',
      content: 'Add ${selected.fullName} to this task?',
      confirmLabel: 'Add',
    );
    if (ok == true) await ctrl.addMember(task.id, selected.id);
  }

  Future<void> _onRemoveMember(
      BuildContext context, TaskMember member) async {
    final ok = await _confirm(
      context,
      title: 'Remove Member',
      content: 'Remove ${member.employeeName} from this task?',
      confirmLabel: 'Remove',
      confirmColor: Colors.red,
    );
    if (ok == true) await ctrl.removeMember(task.id, member.id);
  }

  // ── Primary action ────────────────────────────────────────────────────────

  Future<void> _handleAction(BuildContext context) async {
    if (ctrl.actionLoading.value) return;
    ctrl.actionLoading.value = true;
    final bool success;
    if (showProgress) {
      success = await ctrl.setInReview(task);
    } else if (showMembers) {
      success = await ctrl.setInProgress(task);
    } else {
      success = await ctrl.acceptTask(task);
    }
    ctrl.actionLoading.value = false;
    if (success && context.mounted) Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Expanded(child: _buildContent(context, scrollController)),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 8),
      children: [
        // Drag handle
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

        // Title + status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.3),
              ),
            ),
            const SizedBox(width: 12),
            StatusBadgeWidget(
                label: task.status.name,
                color: task.status.color,
                isDark: isDark),
          ],
        ),

        // Description
        if ((task.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            task.description!,
            style: TextStyle(fontSize: 14, color: mutedColor, height: 1.6),
          ),
        ],

        const SizedBox(height: 20),
        Divider(height: 1, color: divColor),
        const SizedBox(height: 20),

        // Detail rows
        if ((task.labelName ?? task.groupName) != null) ...[
          TaskDetailRow(
            icon: Icons.label_outline_rounded,
            label: 'Label',
            isDark: isDark,
            child: TaskLabelChip(
                name: task.labelName ?? task.groupName!,
                color: task.status.color,
                isDark: isDark),
          ),
          const SizedBox(height: 16),
        ],
        TaskDetailRow(
          icon: Icons.flag_outlined,
          label: 'Priority',
          isDark: isDark,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: task.priority.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(task.priority.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor)),
            ],
          ),
        ),
        if (task.startDate != null) ...[
          const SizedBox(height: 16),
          TaskDetailRow(
            icon: Icons.today_rounded,
            label: 'Start Date',
            isDark: isDark,
            child: _dateText(formatDate(task.startDate!)),
          ),
        ],
        if (task.dueDate != null) ...[
          const SizedBox(height: 16),
          TaskDetailRow(
            icon: Icons.event_rounded,
            label: 'Due Date',
            isDark: isDark,
            child: _dateText(formatDate(task.dueDate!)),
          ),
        ],
        const SizedBox(height: 16),
        TaskDetailRow(
          icon: Icons.person_outline_rounded,
          label: 'Assigned to',
          isDark: isDark,
          child: task.assignedToName != null
              ? TaskAssigneeRow(
                  name: task.assignedToName!,
                  isDark: isDark,
                  imageUrl: task.assignedToProfileImageUrl,
                )
              : Text('Not assigned yet',
                  style: TextStyle(fontSize: 14, color: mutedColor)),
        ),
        const SizedBox(height: 16),
        TaskDetailRow(
          icon: Icons.access_time_rounded,
          label: 'Created',
          isDark: isDark,
          child: _dateText(formatDate(task.createdAt ?? DateTime.now())),
        ),

        // Members section
        if (showMembers || showProgress) ...[
          const SizedBox(height: 24),
          Divider(height: 1, color: divColor),
          const SizedBox(height: 16),
          TaskMembersSection(
            ctrl: ctrl,
            isDark: isDark,
            textColor: textColor,
            mutedColor: mutedColor,
            canEdit: !readOnly && task.assignedToId == ctrl.currentEmployeeId,
            onAdd: (members) => _onAddMember(context, members),
            onRemove: (member) => _onRemoveMember(context, member),
          ),
        ],

        // Progress section
        if (showProgress) ...[
          const SizedBox(height: 24),
          Divider(height: 1, color: divColor),
          const SizedBox(height: 16),
          TaskProgressSection(
            ctrl: ctrl,
            taskId: task.id,
            isDark: isDark,
            textColor: textColor,
            mutedColor: mutedColor,
            canEdit: task.assignedToId == ctrl.currentEmployeeId,
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _dateText(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      );

  Widget _buildBottomBar(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        border: Border(top: BorderSide(color: divColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TaskSheetButton(
              label: readOnly ? 'Close' : 'Cancel',
              isDark: isDark,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (!readOnly) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final loading = ctrl.actionLoading.value;
                return ElevatedButton(
                  onPressed: loading ? null : () => _handleAction(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          showProgress
                              ? 'Mark as Review'
                              : showMembers
                                  ? 'In Progress'
                                  : 'Accept',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
