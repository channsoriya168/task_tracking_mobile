import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_comment_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_member_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_progress_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_picker_sheet.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_comments_tab.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_members_section.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_progress_section.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/task_sheet_widgets.dart';

Future<void> showEmployeeTaskDetailSheet(
  BuildContext context,
  bool isDark,
  TaskItem task, {
  bool readOnly = false,
}) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) =>
      _EmployeeTaskDetailSheet(task: task, isDark: isDark, readOnly: readOnly),
);

class _EmployeeTaskDetailSheet extends StatefulWidget {
  const _EmployeeTaskDetailSheet({
    required this.task,
    required this.isDark,
    required this.readOnly,
  });

  final TaskItem task;
  final bool isDark;
  final bool readOnly;

  @override
  State<_EmployeeTaskDetailSheet> createState() =>
      _EmployeeTaskDetailSheetState();
}

class _EmployeeTaskDetailSheetState extends State<_EmployeeTaskDetailSheet> {
  int _selectedTab = 0;

  /// ID of the transition currently in flight. -1 = Accept. null = idle.
  final _loadingId = Rxn<int>();

  EmployeeTaskController get ctrl => Get.find<EmployeeTaskController>();
  TaskMemberController get memberCtrl => Get.find<TaskMemberController>();
  TaskCommentController get commentCtrl => Get.find<TaskCommentController>();
  TaskProgressController get progressCtrl => Get.find<TaskProgressController>();

  bool get isDark => widget.isDark;
  TaskItem get task => widget.task;
  bool get readOnly => widget.readOnly;

  Color get textColor => isDark ? Colors.white : kTextDark;
  Color get mutedColor => isDark ? Colors.white38 : kTextMuted;
  Color get divColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  static const _tabs = [
    (Icons.group_outlined, 'Members'),
    (Icons.chat_bubble_outline_rounded, 'Comments'),
    (Icons.trending_up_rounded, 'Progress'),
  ];

  // ── Action helpers ───────────────────────────────────────────────────────

  bool get _isPending => task.assignedToId == null;
  bool get _isMyTask => task.assignedToId == ctrl.currentEmployeeId;
  bool get _hasActions =>
      !readOnly &&
      task.allowedTransitions.isNotEmpty &&
      (_isPending || _isMyTask);

  Future<void> _handleAccept() async {
    if (_loadingId.value != null) return;
    _loadingId.value = -1;
    final success = await ctrl.acceptTask(task);
    _loadingId.value = null;
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _handleTransition(TaskStatusLookup newStatus) async {
    if (_loadingId.value != null) return;
    _loadingId.value = newStatus.id;
    final success = await ctrl.transitionTask(task, newStatus);
    _loadingId.value = null;
    if (success && mounted) Navigator.pop(context);
  }

  // ── Member helpers ───────────────────────────────────────────────────────

  Future<void> _onAddMember(List<TaskMember> currentMembers) async {
    if (memberCtrl.groupEmployees.isEmpty)
      await memberCtrl.fetchGroupEmployees();

    final addedIds = currentMembers.map((m) => m.employeeId).toSet();
    final available = memberCtrl.groupEmployees
        .where(
          (e) => !addedIds.contains(e.id) && e.id != ctrl.currentEmployeeId,
        )
        .toList();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Employee>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EmployeePickerSheet(employees: available, isDark: isDark),
    );
    if (selected == null || !mounted) return;

    final ok = await _confirmDialog(
      title: 'Add Member',
      content: 'Add ${selected.fullName} to this task?',
      confirmLabel: 'Add',
    );
    if (ok == true) await memberCtrl.addMember(task.id, selected.id);
  }

  Future<void> _onRemoveMember(TaskMember member) async {
    final ok = await _confirmDialog(
      title: 'Remove Member',
      content: 'Remove ${member.employeeName} from this task?',
      confirmLabel: 'Remove',
      confirmColor: Colors.red,
    );
    if (ok == true) await memberCtrl.removeMember(task.id, member.id);
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    Color confirmColor = kPrimary,
  }) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: isDark ? kCardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : kTextDark,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : kTextMuted,
          height: 1.5,
        ),
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
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Expanded(child: _buildBody(scrollController)),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      children: [
        // ── Handle + close ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
          child: Row(
            children: [
              const Spacer(),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: isDark ? Colors.white60 : kTextMuted,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Title + status ────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 52,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                color: task.status.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            StatusBadgeWidget(
              label: task.status.name,
              color: task.status.color,
              isDark: isDark,
            ),
          ],
        ),

        // ── Description ───────────────────────────────────────
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

        // ── Detail rows ───────────────────────────────────────
        if (task.groupName != null || task.labelName != null) ...[
          TaskDetailRow(
            icon: Icons.label_outline_rounded,
            label: task.labelName != null ? 'Label' : 'Group',
            isDark: isDark,
            child: TaskLabelChip(
              name: task.labelName ?? task.groupName!,
              color: task.status.color,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),
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
                  color: task.priority.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                task.priority.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        if (task.startDate != null) ...[
          const SizedBox(height: 14),
          TaskDetailRow(
            icon: Icons.play_circle_outline_rounded,
            label: 'Start Date',
            isDark: isDark,
            child: _dateText(formatDate(task.startDate!)),
          ),
        ],
        if (task.dueDate != null) ...[
          const SizedBox(height: 14),
          TaskDetailRow(
            icon: Icons.event_rounded,
            label: 'Due Date',
            isDark: isDark,
            child: _dateText(formatDate(task.dueDate!)),
          ),
        ],
        const SizedBox(height: 14),
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
              : Text(
                  'Not assigned yet',
                  style: TextStyle(fontSize: 14, color: mutedColor),
                ),
        ),
        if (task.createdByEmployeeName != null) ...[
          const SizedBox(height: 14),
          TaskDetailRow(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Created by',
            isDark: isDark,
            child: TaskAssigneeRow(
              name: task.createdByEmployeeName!,
              isDark: isDark,
              imageUrl: task.createdByProfileImageUrl,
            ),
          ),
        ],
        const SizedBox(height: 14),
        TaskDetailRow(
          icon: Icons.access_time_rounded,
          label: 'Created',
          isDark: isDark,
          child: _dateText(formatDate(task.createdAt ?? DateTime.now())),
        ),

        const SizedBox(height: 20),
        Divider(height: 1, color: divColor),
        const SizedBox(height: 16),

        _buildTabSection(),
      ],
    );
  }

  Widget _dateText(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
  );

  // ── Tab section ──────────────────────────────────────────────────────────

  Widget _buildTabSection() {
    final canManageMembers =
        !readOnly && task.assignedToId == ctrl.currentEmployeeId;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);

    return Obx(() {
      final counts = [
        memberCtrl.currentTaskMembers.length,
        commentCtrl.currentTaskComments.length,
        progressCtrl.currentTaskProgresses.length,
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill tab bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final (icon, label) = _tabs[i];
                final active = _selectedTab == i;
                final muted = isDark ? Colors.white38 : kTextMuted;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 13,
                            color: active ? Colors.white : muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$label (${counts[i]})',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: active ? Colors.white : muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: switch (_selectedTab) {
                  0 => TaskMembersSection(
                    ctrl: memberCtrl,
                    isDark: isDark,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    canEdit: canManageMembers,
                    onAdd: (members) => _onAddMember(members),
                    onRemove: (member) => _onRemoveMember(member),
                  ),
                  1 => TaskCommentsTab(
                    ctrl: commentCtrl,
                    isDark: isDark,
                    taskId: task.id,
                    canComment:
                        task.assignedToId == ctrl.currentEmployeeId &&
                        !readOnly,
                  ),
                  _ => TaskProgressSection(
                    ctrl: progressCtrl,
                    taskId: task.id,
                    isDark: isDark,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    canEdit: canManageMembers,
                  ),
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  // ── Bottom action bar ────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    if (!_hasActions) return const SizedBox.shrink();

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        border: Border(top: BorderSide(color: divColor)),
      ),
      child: Obx(() {
        final activeId = _loadingId.value;

        if (_isPending) {
          return TaskTransitionButton(
            label: 'Accept',
            color: task.allowedTransitions.first.color,
            loading: activeId == -1,
            onTap: _handleAccept,
          );
        }

        return Row(
          children: [
            for (int i = 0; i < task.allowedTransitions.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: TaskTransitionButton(
                  label: task.allowedTransitions[i].name,
                  color: task.allowedTransitions[i].color,
                  loading: activeId == task.allowedTransitions[i].id,
                  onTap: () => _handleTransition(task.allowedTransitions[i]),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
