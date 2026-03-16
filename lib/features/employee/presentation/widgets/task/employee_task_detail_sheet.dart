import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/employee.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/status_badge_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';

Future<void> showEmployeeTaskDetailSheet(
  BuildContext context,
  bool isDark,
  TaskItem task, {
  bool showMembers = false,
  bool readOnly = false,
}) async {
  final ctrl = Get.find<EmployeeTaskController>();
  if (showMembers) {
    ctrl.fetchTaskMembers(task.id);
    ctrl.fetchGroupEmployees();
  }
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TaskDetailSheet(
      task: task,
      isDark: isDark,
      ctrl: ctrl,
      showMembers: showMembers,
      readOnly: readOnly,
    ),
  );
}

// ── Sheet widget ──────────────────────────────────────────────────────────────

class _TaskDetailSheet extends StatefulWidget {
  const _TaskDetailSheet({
    required this.task,
    required this.isDark,
    required this.ctrl,
    required this.showMembers,
    required this.readOnly,
  });

  final TaskItem task;
  final bool isDark;
  final EmployeeTaskController ctrl;
  final bool showMembers;
  final bool readOnly;

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  bool _loading = false;

  TaskItem get task => widget.task;
  bool get isDark => widget.isDark;
  EmployeeTaskController get ctrl => widget.ctrl;

  Color get textColor => isDark ? Colors.white : kTextDark;
  Color get mutedColor => isDark ? Colors.white38 : kTextMuted;
  Color get divColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  // ── Dialogs ───────────────────────────────────────────────────────────────

  Future<bool?> _confirm({
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
                style:
                    TextStyle(color: isDark ? Colors.white54 : kTextMuted),
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

  Future<void> _onAddMember(List<TaskMember> currentMembers) async {
    if (ctrl.groupEmployees.isEmpty) await ctrl.fetchGroupEmployees();

    final addedIds = currentMembers.map((m) => m.employeeId).toSet();
    final available = ctrl.groupEmployees
        .where((e) => !addedIds.contains(e.id) && e.id != ctrl.currentEmployeeId)
        .toList();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Employee>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EmployeePickerSheet(employees: available, isDark: isDark),
    );
    if (selected == null || !mounted) return;

    final ok = await _confirm(
      title: 'Add Member',
      content: 'Add ${selected.fullName} to this task?',
      confirmLabel: 'Add',
    );
    if (ok == true && mounted) await ctrl.addMember(task.id, selected.id);
  }

  Future<void> _onRemoveMember(TaskMember member) async {
    final ok = await _confirm(
      title: 'Remove Member',
      content: 'Remove ${member.employeeName} from this task?',
      confirmLabel: 'Remove',
      confirmColor: Colors.red,
    );
    if (ok == true && mounted) await ctrl.removeMember(task.id, member.id);
  }

  // ── Primary action (Accept / In Progress) ─────────────────────────────────

  Future<void> _handleAction() async {
    if (_loading) return;
    setState(() => _loading = true);
    final success = widget.showMembers
        ? await ctrl.setInProgress(task)
        : await ctrl.acceptTask(task);
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) Navigator.pop(context);
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
            Expanded(child: _buildContent(scrollController)),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
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
          _DetailRow(
            icon: Icons.label_outline_rounded,
            label: 'Label',
            isDark: isDark,
            child: _LabelChip(
                name: task.labelName ?? task.groupName!,
                color: task.status.color,
                isDark: isDark),
          ),
          const SizedBox(height: 16),
        ],
        _DetailRow(
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
          _DetailRow(
            icon: Icons.today_rounded,
            label: 'Start Date',
            isDark: isDark,
            child: _dateText(formatDate(task.startDate!)),
          ),
        ],
        if (task.dueDate != null) ...[
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.event_rounded,
            label: 'Due Date',
            isDark: isDark,
            child: _dateText(formatDate(task.dueDate!)),
          ),
        ],
        const SizedBox(height: 16),
        _DetailRow(
          icon: Icons.person_outline_rounded,
          label: 'Assigned to',
          isDark: isDark,
          child: task.assignedToName != null
              ? _AssigneeRow(name: task.assignedToName!, isDark: isDark)
              : Text('Not assigned yet',
                  style: TextStyle(fontSize: 14, color: mutedColor)),
        ),
        const SizedBox(height: 16),
        _DetailRow(
          icon: Icons.access_time_rounded,
          label: 'Created',
          isDark: isDark,
          child: _dateText(formatDate(task.createdAt ?? DateTime.now())),
        ),

        // Members section (assigned tasks only)
        if (widget.showMembers) ...[
          const SizedBox(height: 24),
          Divider(height: 1, color: divColor),
          const SizedBox(height: 16),
          _MembersSection(
            ctrl: ctrl,
            isDark: isDark,
            textColor: textColor,
            mutedColor: mutedColor,
            onAdd: _onAddMember,
            onRemove: _onRemoveMember,
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
            child: _SheetButton(
              label: widget.readOnly ? 'Close' : 'Cancel',
              isDark: isDark,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (!widget.readOnly) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _loading ? null : _handleAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.showMembers ? 'In Progress' : 'Accept',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Members section ───────────────────────────────────────────────────────────

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.ctrl,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.onAdd,
    required this.onRemove,
  });

  final EmployeeTaskController ctrl;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final void Function(List<TaskMember>) onAdd;
  final void Function(TaskMember) onRemove;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final members = ctrl.currentTaskMembers.toList();
      final loading = ctrl.membersLoading.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group_outlined, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Text('Members',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const Spacer(),
              GestureDetector(
                onTap: () => onAdd(members),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child:
                      const Icon(Icons.add, size: 16, color: kPrimary),
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
          else if (members.isEmpty)
            Text('No members yet. Tap + to add.',
                style: TextStyle(fontSize: 13, color: mutedColor))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: members
                  .map((m) => _MemberAvatar(
                      member: m,
                      isDark: isDark,
                      onRemove: () => onRemove(m)))
                  .toList(),
            ),
        ],
      );
    });
  }
}

// ── Member avatar ─────────────────────────────────────────────────────────────

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar(
      {required this.member, required this.isDark, required this.onRemove});

  final TaskMember member;
  final bool isDark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor:
                  kPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
              backgroundImage: member.employeeProfileImageUrl != null
                  ? NetworkImage(member.employeeProfileImageUrl!)
                  : null,
              child: member.employeeProfileImageUrl == null
                  ? Text(
                      member.employeeName.isNotEmpty
                          ? member.employeeName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kPrimary),
                    )
                  : null,
            ),
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDark ? kCardDark : Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, size: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          child: Text(
            member.employeeName.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white60 : kTextMuted),
          ),
        ),
      ],
    );
  }
}

// ── Employee picker sheet ─────────────────────────────────────────────────────

class _EmployeePickerSheet extends StatefulWidget {
  const _EmployeePickerSheet(
      {required this.employees, required this.isDark});

  final List<Employee> employees;
  final bool isDark;

  @override
  State<_EmployeePickerSheet> createState() => _EmployeePickerSheetState();
}

class _EmployeePickerSheetState extends State<_EmployeePickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.employees
        .where((e) => e.fullName.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    final bg = widget.isDark ? kCardDark : Colors.white;
    final textColor = widget.isDark ? Colors.white : kTextDark;
    final mutedColor = widget.isDark ? Colors.white38 : kTextMuted;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Select Employee',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: mutedColor),
                prefixIcon: Icon(Icons.search, color: mutedColor, size: 18),
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No employees found.',
                        style: TextStyle(color: mutedColor)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (_, i) {
                      final emp = filtered[i];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: kPrimary.withValues(alpha: 0.15),
                          child: Text(emp.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimary)),
                        ),
                        title: Text(emp.fullName,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor)),
                        subtitle: Text(emp.email,
                            style:
                                TextStyle(fontSize: 12, color: mutedColor)),
                        onTap: () => Navigator.pop(context, emp),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _LabelChip extends StatelessWidget {
  const _LabelChip(
      {required this.name, required this.color, required this.isDark});
  final String name;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(name,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _AssigneeRow extends StatelessWidget {
  const _AssigneeRow({required this.name, required this.isDark});
  final String name;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(name[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: kPrimary)),
        ),
        const SizedBox(width: 8),
        Text(name,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : kTextDark)),
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton(
      {required this.label, required this.isDark, required this.onPressed});
  final String label;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color:
              isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.15),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : kTextMuted),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.child,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: mutedColor)),
        ),
        Expanded(child: child),
      ],
    );
  }
}
