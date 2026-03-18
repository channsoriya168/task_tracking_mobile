import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/helper/format_date.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_detail_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/task_group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_avatar_name_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_colored_chip_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_row_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_status_priority_row_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task/task_detail_tab_section_widget.dart';

Future<void> showTaskDetailSheet(
  BuildContext context,
  bool isDark,
  TaskItem task, {
  Future<TaskItem?> Function(String id)? fetchDetail,
}) async {
  TaskItemRepository? repo;
  try {
    repo = Get.find<TaskItemRepository>();
  } catch (_) {}

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TaskDetailSheet(
      task: task,
      isDark: isDark,
      repo: repo,
      fetchDetail: fetchDetail,
    ),
  );
}

// ── StatefulWidget — owns the controller lifecycle ───────────────────────────
class _TaskDetailSheet extends StatefulWidget {
  const _TaskDetailSheet({
    required this.task,
    required this.isDark,
    required this.repo,
    required this.fetchDetail,
  });

  final TaskItem task;
  final bool isDark;
  final TaskItemRepository? repo;
  final Future<TaskItem?> Function(String id)? fetchDetail;

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  late final TaskDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(
      TaskDetailController(widget.repo, widget.task),
      tag: widget.task.id,
    );
    if (widget.fetchDetail != null) _ctrl.loadFresh(widget.fetchDetail!);
  }

  @override
  void dispose() {
    Get.delete<TaskDetailController>(tag: widget.task.id, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => _TaskDetailSheetContent(
        ctrl: _ctrl,
        isDark: widget.isDark,
        scrollController: scrollController,
      ),
    );
  }
}

// ── Sheet shell ──────────────────────────────────────────────────────────────
class _TaskDetailSheetContent extends StatelessWidget {
  const _TaskDetailSheetContent({
    required this.ctrl,
    required this.isDark,
    required this.scrollController,
  });

  final TaskDetailController ctrl;
  final bool isDark;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header: drag handle + close button + loading bar ──
          Obx(() => Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Drag handle (centered)
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
                        // Close button
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
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
                    if (ctrl.isLoadingTask.value) ...[
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
              )),

          // ── Scrollable body ──────────────────────────────────
          Expanded(
            child: Obx(() {
              final task = ctrl.task.value;
              return _TaskDetailBody(
                task: task,
                ctrl: ctrl,
                isDark: isDark,
                scrollController: scrollController,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Body (rebuilds when task changes) ────────────────────────────────────────
class _TaskDetailBody extends StatelessWidget {
  const _TaskDetailBody({
    required this.task,
    required this.ctrl,
    required this.isDark,
    required this.scrollController,
  });

  final TaskItem task;
  final TaskDetailController ctrl;
  final bool isDark;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
    final statusColor = task.status.color;

    TaskGroupController? groupCtrl;
    try {
      groupCtrl = Get.find<TaskGroupController>();
    } catch (_) {}
    final taskGroup =
        task.groupId != null ? groupCtrl?.findPosition(task.groupId!) : null;
    final groupColor = taskGroup?.color ?? kPrimary;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      children: [
        // ── Title + status strip ──────────────────────────────
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
                    task.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TaskDetailStatusPriorityRow(task: task, isDark: isDark),
                ],
              ),
            ),
          ],
        ),

        // ── Description ───────────────────────────────────────
        if ((task.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            task.description!,
            style: TextStyle(fontSize: 14, color: mutedColor, height: 1.6),
          ),
        ],

        const SizedBox(height: 20),
        Divider(height: 1, color: divColor),
        const SizedBox(height: 20),

        // ── Task Group ────────────────────────────────────────
        TaskDetailRow(
          icon: Icons.folder_outlined,
          label: 'Task Group',
          isDark: isDark,
          child: task.groupName != null
              ? TaskDetailColoredChip(
                  label: task.groupName!,
                  color: groupColor,
                  isDark: isDark,
                )
              : Text('—', style: TextStyle(fontSize: 14, color: mutedColor)),
        ),
        const SizedBox(height: 14),

        // ── Label ─────────────────────────────────────────────
        if (task.labelName != null) ...[
          TaskDetailRow(
            icon: Icons.label_outline_rounded,
            label: 'Label',
            isDark: isDark,
            child: TaskDetailColoredChip(
              label: task.labelName!,
              color: task.labelColor != null
                  ? _hexToColor(task.labelColor!)
                  : kPrimary,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Start date ────────────────────────────────────────
        if (task.startDate != null) ...[
          TaskDetailRow(
            icon: Icons.play_circle_outline_rounded,
            label: 'Start Date',
            isDark: isDark,
            child: Text(
              formatDate(task.startDate!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Due date ──────────────────────────────────────────
        if (task.dueDate != null) ...[
          TaskDetailRow(
            icon: Icons.event_rounded,
            label: 'Due Date',
            isDark: isDark,
            child: Text(
              formatDate(task.dueDate!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Completed at ──────────────────────────────────────
        if (task.completedAt != null) ...[
          TaskDetailRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Completed',
            isDark: isDark,
            child: Text(
              formatDate(task.completedAt!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Assigned to ───────────────────────────────────────
        TaskDetailRow(
          icon: Icons.person_outline_rounded,
          label: 'Assigned to',
          isDark: isDark,
          child: task.assignedToName != null
              ? TaskDetailAvatarName(
                  name: task.assignedToName!,
                  color: kPrimary,
                  textColor: textColor,
                )
              : Text(
                  'Not assigned',
                  style: TextStyle(fontSize: 14, color: mutedColor),
                ),
        ),
        const SizedBox(height: 14),

        // ── Created by ────────────────────────────────────────
        if (task.createdByEmployeeName != null) ...[
          TaskDetailRow(
            icon: Icons.edit_outlined,
            label: 'Created by',
            isDark: isDark,
            child: TaskDetailAvatarName(
              name: task.createdByEmployeeName!,
              color: mutedColor,
              textColor: textColor,
            ),
          ),
          const SizedBox(height: 14),
        ],

        const SizedBox(height: 8),
        Divider(height: 1, color: divColor),
        const SizedBox(height: 16),

        // ── Members / Comments / Progress tabs ────────────────
        TaskDetailTabSection(ctrl: ctrl, isDark: isDark),
      ],
    );
  }
}

Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  return kPrimary;
}
