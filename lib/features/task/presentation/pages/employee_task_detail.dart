import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/utils/app_snackbar.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/employee/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/dashboard/controllers/employee_home_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_member_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_comment_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_progress_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/employee_picker_sheet.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_comments_tab.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_members_section.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_progress_section.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_sheet_widgets.dart';

class EmployeeTaskDetailPage extends StatefulWidget {
  const EmployeeTaskDetailPage({
    super.key,
    required this.task,
    required this.isDark,
    this.readOnly = false,
  });

  final TaskItem task;
  final bool isDark;
  final bool readOnly;

  @override
  State<EmployeeTaskDetailPage> createState() => _EmployeeTaskDetailPageState();
}

class _EmployeeTaskDetailPageState extends State<EmployeeTaskDetailPage> {
  int _selectedTab = 0;

  /// ID of the transition currently in flight. -1 = Accept. null = idle.
  final _loadingId = Rxn<int>();

  EmployeeTaskController get ctrl => Get.find<EmployeeTaskController>();
  EmployeeTaskMemberController get memberCtrl =>
      Get.find<EmployeeTaskMemberController>();
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

  List<(IconData, String)> get _tabs => [
    (Icons.group_outlined, 'member_title'.tr),
    (Icons.chat_bubble_outline_rounded, 'comment_title'.tr),
    (Icons.trending_up_rounded, 'progress_title'.tr),
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
    final success = await Get.find<EmployeeHomeController>().acceptTask(task);
    _loadingId.value = null;
    if (success && mounted) {
      Get.back();
      AppSnackbar.success(
        'snack_task_accepted'.tr,
        'snack_task_accepted_msg'.trParams({'title': task.title}),
      );
      Get.find<NavigationController>().changePage(1);
    }
  }

  Future<void> _handleTransition(TaskStatusLookup newStatus) async {
    if (_loadingId.value != null) return;
    _loadingId.value = newStatus.id;
    final success = await ctrl.transitionTask(task, newStatus);
    _loadingId.value = null;
    if (success && mounted) {
      Get.back();
      AppSnackbar.update(
        'snack_status_updated'.tr,
        'snack_status_updated_msg'.trParams({'status': newStatus.name}),
      );
    }
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
      title: 'member_add_title'.tr,
      content: 'member_add_confirm'.trParams({'name': selected.fullName}),
      confirmLabel: 'action_add'.tr,
    );
    if (ok == true) await memberCtrl.addMember(task.id, selected.id);
  }

  Future<void> _onRemoveMember(TaskMember member) async {
    final ok = await _confirmDialog(
      title: 'member_remove_title'.tr,
      content: 'member_remove_confirm'.trParams({'name': member.employeeName}),
      confirmLabel: 'action_remove'.tr,
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
    return Scaffold(
      backgroundColor: isDark ? kCardDark : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? kCardDark : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : kTextDark,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'task_detail_title'.tr,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: divColor),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
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
              label: task.labelName != null
                  ? 'task_detail_label'.tr
                  : 'task_detail_group'.tr,
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
            label: 'task_detail_priority'.tr,
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
              label: 'task_detail_start_date'.tr,
              isDark: isDark,
              child: _dateText(formatDate(task.startDate!)),
            ),
          ],
          if (task.dueDate != null) ...[
            const SizedBox(height: 14),
            TaskDetailRow(
              icon: Icons.event_rounded,
              label: 'task_detail_due_date'.tr,
              isDark: isDark,
              child: _dateText(formatDate(task.dueDate!)),
            ),
          ],
          const SizedBox(height: 14),
          TaskDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'task_detail_assigned_to'.tr,
            isDark: isDark,
            child: task.assignedToName != null
                ? TaskAssigneeRow(
                    name: task.assignedToName!,
                    isDark: isDark,
                    imageUrl: task.assignedToProfileImageUrl,
                  )
                : Text(
                    'task_detail_not_assigned'.tr,
                    style: TextStyle(fontSize: 14, color: mutedColor),
                  ),
          ),
          if (task.createdByEmployeeName != null) ...[
            const SizedBox(height: 14),
            TaskDetailRow(
              icon: Icons.person_add_alt_1_outlined,
              label: 'task_detail_created_by'.tr,
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
            label: 'task_detail_created'.tr,
            isDark: isDark,
            child: _dateText(formatDate(task.createdAt ?? DateTime.now())),
          ),

          const SizedBox(height: 20),
          Divider(height: 1, color: divColor),
          const SizedBox(height: 16),

          _buildTabSection(),
        ],
      ),
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
            width: double.infinity,
            label: 'task_accept'.tr,
            color: task.allowedTransitions.first.color,
            loading: activeId == -1,
            onTap: _handleAccept,
          );
        }

        final transitions = task.allowedTransitions;
        final useGrid = transitions.length > 2;

        if (!useGrid) {
          return Row(
            children: [
              for (int i = 0; i < transitions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: TaskTransitionButton(
                    label: transitions[i].name,
                    color: transitions[i].color,
                    loading: activeId == transitions[i].id,
                    onTap: () => _handleTransition(transitions[i]),
                  ),
                ),
              ],
            ],
          );
        }

        // 2-column grid for 3+ transitions
        final rows = <Widget>[];
        for (int i = 0; i < transitions.length; i += 2) {
          final hasNext = i + 1 < transitions.length;
          rows.add(
            Row(
              children: [
                Expanded(
                  child: TaskTransitionButton(
                    label: transitions[i].name,
                    color: transitions[i].color,
                    loading: activeId == transitions[i].id,
                    onTap: () => _handleTransition(transitions[i]),
                  ),
                ),
                if (hasNext) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TaskTransitionButton(
                      label: transitions[i + 1].name,
                      color: transitions[i + 1].color,
                      loading: activeId == transitions[i + 1].id,
                      onTap: () => _handleTransition(transitions[i + 1]),
                    ),
                  ),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
          if (i + 2 < transitions.length) rows.add(const SizedBox(height: 8));
        }
        return Column(mainAxisSize: MainAxisSize.min, children: rows);
      }),
    );
  }
}
