import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/task_group_controller.dart';

Future<void> showTaskDetailSheet(
  BuildContext context,
  bool isDark,
  TaskItem task, {
  Future<TaskItem?> Function(String id)? fetchDetail,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => _TaskDetailSheetContent(
        initialTask: task,
        isDark: isDark,
        scrollController: scrollController,
        fetchDetail: fetchDetail,
      ),
    ),
  );
}

// ── Sheet content with optional live fetch ─────────────────────
class _TaskDetailSheetContent extends StatefulWidget {
  const _TaskDetailSheetContent({
    required this.initialTask,
    required this.isDark,
    required this.scrollController,
    this.fetchDetail,
  });

  final TaskItem initialTask;
  final bool isDark;
  final ScrollController scrollController;
  final Future<TaskItem?> Function(String id)? fetchDetail;

  @override
  State<_TaskDetailSheetContent> createState() =>
      _TaskDetailSheetContentState();
}

class _TaskDetailSheetContentState extends State<_TaskDetailSheetContent> {
  late TaskItem _task;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _task = widget.initialTask;
    if (widget.fetchDetail != null) _loadFresh();
  }

  Future<void> _loadFresh() async {
    setState(() => _loading = true);
    final fresh = await widget.fetchDetail!(_task.id);
    if (mounted) {
      setState(() {
        if (fresh != null) _task = fresh;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
    final statusColor = _task.status.color;

    TaskGroupController? posCtrl;
    try {
      posCtrl = Get.find<TaskGroupController>();
    } catch (_) {}
    final taskGroup =
        _task.groupId != null ? posCtrl?.findPosition(_task.groupId!) : null;
    final groupColor = taskGroup?.color ?? kPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle + loading indicator ─────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Column(
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
                if (_loading) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: kPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Scrollable content ────────────────────────────
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              children: [
                // Status strip + title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 52,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _task.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _StatusPriorityRow(
                              task: _task, isDark: isDark),
                        ],
                      ),
                    ),
                  ],
                ),

                // Description
                if ((_task.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    _task.description!,
                    style: TextStyle(
                        fontSize: 14, color: mutedColor, height: 1.6),
                  ),
                ],

                const SizedBox(height: 20),
                Divider(height: 1, color: divColor),
                const SizedBox(height: 20),

                // Task Group
                _DetailRow(
                  icon: Icons.folder_outlined,
                  label: 'Task Group',
                  isDark: isDark,
                  child: _task.groupName != null
                      ? _ColoredChip(
                          label: _task.groupName!,
                          color: groupColor,
                          isDark: isDark,
                        )
                      : Text('—',
                          style: TextStyle(fontSize: 14, color: mutedColor)),
                ),
                const SizedBox(height: 14),

                // Label
                if (_task.labelName != null) ...[
                  _DetailRow(
                    icon: Icons.label_outline_rounded,
                    label: 'Label',
                    isDark: isDark,
                    child: _ColoredChip(
                      label: _task.labelName!,
                      color: _task.labelColor != null
                          ? _hexToColor(_task.labelColor!)
                          : kPrimary,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Start date
                if (_task.startDate != null) ...[
                  _DetailRow(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Start Date',
                    isDark: isDark,
                    child: Text(
                      formatDate(_task.startDate!),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Due date
                if (_task.dueDate != null) ...[
                  _DetailRow(
                    icon: Icons.event_rounded,
                    label: 'Due Date',
                    isDark: isDark,
                    child: Text(
                      formatDate(_task.dueDate!),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Completed at
                if (_task.completedAt != null) ...[
                  _DetailRow(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Completed',
                    isDark: isDark,
                    child: Text(
                      formatDate(_task.completedAt!),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Assigned to
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Assigned to',
                  isDark: isDark,
                  child: _task.assignedToName != null
                      ? _AvatarName(
                          name: _task.assignedToName!,
                          color: kPrimary,
                          textColor: textColor,
                        )
                      : Text('Not assigned',
                          style: TextStyle(fontSize: 14, color: mutedColor)),
                ),
                const SizedBox(height: 14),

                // Created by
                if (_task.createdByEmployeeName != null) ...[
                  _DetailRow(
                    icon: Icons.edit_outlined,
                    label: 'Created by',
                    isDark: isDark,
                    child: _AvatarName(
                      name: _task.createdByEmployeeName!,
                      color: mutedColor,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Created at
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: 'Created',
                  isDark: isDark,
                  child: Text(
                    formatDate(_task.createdAt ?? DateTime.now()),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor),
                  ),
                ),

                // Updated at
                if (_task.updatedAt != null) ...[
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: Icons.update_rounded,
                    label: 'Updated',
                    isDark: isDark,
                    child: Text(
                      formatDate(_task.updatedAt!),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor),
                    ),
                  ),
                ],

                // Allowed transitions
                if (_task.allowedTransitions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Divider(height: 1, color: divColor),
                  const SizedBox(height: 16),
                  Text(
                    'Move to',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _task.allowedTransitions
                        .map((s) => _TransitionChip(
                            status: s, isDark: isDark))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status + priority inline row ───────────────────────────────
class _StatusPriorityRow extends StatelessWidget {
  const _StatusPriorityRow({required this.task, required this.isDark});
  final TaskItem task;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final statusColor = task.status.color;
    final priorityColor = task.priority.color;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            task.status.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          task.priority.name,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : kTextMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Transition chip ────────────────────────────────────────────
class _TransitionChip extends StatelessWidget {
  const _TransitionChip({required this.status, required this.isDark});
  final TaskStatusLookup status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Colored chip ───────────────────────────────────────────────
class _ColoredChip extends StatelessWidget {
  const _ColoredChip(
      {required this.label, required this.color, required this.isDark});
  final String label;
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Avatar + name ──────────────────────────────────────────────
class _AvatarName extends StatelessWidget {
  const _AvatarName(
      {required this.name, required this.color, required this.textColor});
  final String name;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Detail row ─────────────────────────────────────────────────
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
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: mutedColor),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ── Hex color helper ───────────────────────────────────────────
Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    return Color(int.parse('FF$h', radix: 16));
  }
  return kPrimary;
}