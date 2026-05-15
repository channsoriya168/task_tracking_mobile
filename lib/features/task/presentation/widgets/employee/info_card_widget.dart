import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/utils/format_date.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_sheet_widgets.dart';

class InfoCardWidget extends StatelessWidget {
  const InfoCardWidget({
    super.key,
    required this.surfaceColor,
    required this.mutedColor,
    required this.task,
    required this.isDark,
  });
  final TaskItem task;
  final Color surfaceColor;
  final Color mutedColor;
  final bool isDark;
  Color get divColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  @override
  Widget build(BuildContext context) {
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
          // label
          if (task.labelName != null) ...[
            _infoRow(
              'task_detail_label'.tr,
              Text(
                task.labelName!,
                style: AppTextStyles.subTitle(color: mutedColor),
              ),
            ),
            Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
          ],
          if (task.groupName != null) ...[
            _infoRow(
              'task_detail_group'.tr,
              Text(
                task.groupName!,
                style: AppTextStyles.subTitle(color: mutedColor),
              ),
            ),
            Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
          ],
          //start date
          if (task.startDate != null) ...[
            _infoRow(
              'task_detail_start_date'.tr,
              _dateText(formatDate(task.startDate!), mutedColor),
            ),
            Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
          ],
          //due date
          if (task.dueDate != null) ...[
            _infoRow(
              'task_detail_due_date'.tr,
              _dateText(formatDate(task.dueDate!), mutedColor),
            ),
            Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
          ],
          //assigned to
          if (task.assignedToName != null) ...[
            _infoRow(
              'task_detail_assigned_to'.tr,
              TaskAssigneeRow(
                name: task.assignedToName!,
                isDark: isDark,
                imageUrl: task.assignedToProfileImageUrl,
              ),
            ),
            Divider(height: 1, indent: 16, endIndent: 16, color: divColor),
          ],
          //created by
          if (task.createdByEmployeeName != null) ...[
            _infoRow(
              'task_detail_created_by'.tr,
              TaskAssigneeRow(
                name: task.createdByEmployeeName!,
                isDark: isDark,
                imageUrl: task.createdByProfileImageUrl,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.subTitle(color: mutedColor),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ],
      ),
    );
  }
}

Widget _dateText(String text, Color color) =>
    Text(text, style: AppTextStyles.subTitle(color: color));
