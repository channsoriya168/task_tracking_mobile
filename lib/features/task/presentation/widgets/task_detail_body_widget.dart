import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_detail_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_avatar_name_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_colored_chip_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_status_priority_row_widget.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_tab_section_widget.dart';

class TaskDetailBodyWidget extends StatelessWidget {
  const TaskDetailBodyWidget({
    super.key,
    required this.task,
    required this.ctrl,
    required this.isDark,
    required this.scrollController,
  });

  final TaskItem task;
  final TaskDetailController ctrl;
  final bool isDark;
  final ScrollController scrollController;

  Color get textColor => isDark ? Colors.white : kTextDark;
  Color get mutedColor => isDark ? Colors.white38 : kTextMuted;
  Color get divColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        // ── Header card ───────────────────────────────────────
        _buildHeaderCard(),

        const SizedBox(height: 12),

        // ── Info card ─────────────────────────────────────────
        _buildInfoCard(),

        const SizedBox(height: 12),

        // ── Members / Comments / Progress tabs ────────────────
        TaskDetailTabSection(ctrl: ctrl, isDark: isDark),
      ],
    );
  }

  // ── Header card (title + status + description) ───────────────────────────

  Widget _buildHeaderCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.title(color: textColor).copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TaskDetailStatusPriorityRow(task: task, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
          if ((task.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              task.description!,
              style: AppTextStyles.subTitle(color: mutedColor).copyWith(
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Info card (detail rows grouped) ─────────────────────────────────────

  Widget _buildInfoCard() {
    final rows = <Widget>[];

    void addRow(Widget row) {
      if (rows.isNotEmpty) {
        rows.add(
          Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
        );
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: row,
        ),
      );
    }

    if (task.labelName != null) {
      addRow(
        _buildInfoRow(
          icon: Icons.label_outline_rounded,
          label: 'Label',
          child: TaskDetailColoredChip(
            label: task.labelName!,
            color: task.labelColor != null
                ? _hexToColor(task.labelColor!)
                : kPrimary,
            isDark: isDark,
          ),
        ),
      );
    }

    if (task.startDate != null) {
      addRow(
        _buildInfoRow(
          icon: Icons.play_circle_outline_rounded,
          label: 'Start Date',
          child: _dateText(formatDate(task.startDate!)),
        ),
      );
    }

    if (task.dueDate != null) {
      addRow(
        _buildInfoRow(
          icon: Icons.event_rounded,
          label: 'Due Date',
          child: _dateText(formatDate(task.dueDate!)),
        ),
      );
    }

    if (task.completedAt != null) {
      addRow(
        _buildInfoRow(
          icon: Icons.check_circle_outline_rounded,
          label: 'Completed',
          child: _dateText(formatDate(task.completedAt!)),
        ),
      );
    }

    addRow(
      _buildInfoRow(
        icon: Icons.person_outline_rounded,
        label: 'Assigned to',
        child: task.assignedToName != null
            ? TaskDetailAvatarName(
                name: task.assignedToName!,
                color: kPrimary,
                textColor: textColor,
              )
            : Text(
                'Not assigned',
                style: AppTextStyles.subTitle(color: mutedColor).copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );

    if (task.createdByEmployeeName != null) {
      addRow(
        _buildInfoRow(
          icon: Icons.person_add_alt_1_outlined,
          label: 'Created by',
          child: TaskDetailAvatarName(
            name: task.createdByEmployeeName!,
            color: mutedColor,
            textColor: textColor,
          ),
        ),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: Column(children: rows),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: kPrimary),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: AppTextStyles.formLabel(color: mutedColor).copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: isDark ? kCardDark : Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _dateText(String text) => Text(
    text,
    style: AppTextStyles.formLabel(color: textColor),
  );
}

Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  return kPrimary;
}
