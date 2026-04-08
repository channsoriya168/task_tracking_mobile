import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_member_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_comment_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_progress_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/build_bottom_bar_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/header_card_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/tab_section_widget.dart';

import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_sheet_widgets.dart';

class EmployeeTaskDetailPage extends StatelessWidget {
  const EmployeeTaskDetailPage({
    super.key,
    required this.task,
    required this.isDark,
    this.readOnly = false,
  });

  final TaskItem task;
  final bool isDark;
  final bool readOnly;

  EmployeeTaskController get ctrl => Get.find<EmployeeTaskController>();
  EmployeeTaskMemberController get memberCtrl =>
      Get.find<EmployeeTaskMemberController>();
  TaskCommentController get commentCtrl => Get.find<TaskCommentController>();
  TaskProgressController get progressCtrl => Get.find<TaskProgressController>();

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

  Color get surfaceColor => isDark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.black.withValues(alpha: 0.03);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : kTextDark,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'task_detail_title'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ),
      bottomNavigationBar: BuildBottomBarWidget(
        hasActions: _hasActions,
        isDark: isDark,
        divColor: divColor,
        ctrl: ctrl,
        isPending: _isPending,
        task: task,
        context: context,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ── Header card ───────────────────────────────────────
          HeaderCardWidget(task: task, isDark: isDark),

          const SizedBox(height: 12),

          // ── Info card ─────────────────────────────────────────
          _buildInfoCard(),

          const SizedBox(height: 12),

          // ── Tabs ──────────────────────────────────────────────
          TabSectionWidget(
            readOnly: readOnly,
            task: task,
            ctrl: ctrl,
            memberCtrl: memberCtrl,
            commentCtrl: commentCtrl,
            progressCtrl: progressCtrl,
            isDark: isDark,
            tabs: _tabs,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ],
      ),
    );
  }

  // ── Header card (title + status + description) ───────────────────────────

  // ── Info card (detail rows grouped) ─────────────────────────────────────

  Widget _buildInfoCard() {
    final rows = <_InfoEntry>[];

    if (task.groupName != null || task.labelName != null) {
      rows.add(
        _InfoEntry(
          icon: Icons.label_outline_rounded,
          label: task.labelName != null
              ? 'task_detail_label'.tr
              : 'task_detail_group'.tr,
          child: Text(
            task.labelName!,
            style: TextStyle(fontSize: 13.5, color: mutedColor),
          ),
        ),
      );
    }

    if (task.startDate != null) {
      rows.add(
        _InfoEntry(
          icon: Icons.play_circle_outline_rounded,
          label: 'task_detail_start_date'.tr,
          child: _dateText(formatDate(task.startDate!)),
        ),
      );
    }

    if (task.dueDate != null) {
      rows.add(
        _InfoEntry(
          icon: Icons.event_rounded,
          label: 'task_detail_due_date'.tr,
          child: _dateText(formatDate(task.dueDate!)),
        ),
      );
    }

    rows.add(
      _InfoEntry(
        icon: Icons.person_outline_rounded,
        label: 'task_detail_assigned_to'.tr,
        child: task.assignedToName != null
            ? TaskAssigneeRow(
                name: task.assignedToName!,
                isDark: isDark,
                imageUrl: task.assignedToProfileImageUrl,
              )
            : Text(
                'task_detail_not_assigned'.tr,
                style: TextStyle(fontSize: 13.5, color: mutedColor),
              ),
      ),
    );

    if (task.createdByEmployeeName != null) {
      rows.add(
        _InfoEntry(
          icon: Icons.person_add_alt_1_outlined,
          label: 'task_detail_created_by'.tr,
          child: TaskAssigneeRow(
            name: task.createdByEmployeeName!,
            isDark: isDark,
            imageUrl: task.createdByProfileImageUrl,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: _buildInfoRow(rows[i]),
            ),
            if (i < rows.length - 1)
              Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoEntry entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(entry.icon, size: 15, color: kPrimary),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            entry.label,
            style: TextStyle(
              fontSize: 12,
              color: mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: entry.child),
        ),
      ],
    );
  }

  Widget _dateText(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
  );
}

// ── Helper ────────────────────────────────────────────────────────────────────

class _InfoEntry {
  const _InfoEntry({
    required this.icon,
    required this.label,
    required this.child,
  });
  final IconData icon;
  final String label;
  final Widget child;
}
