import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/filter_chip_widget.dart';

class TaskFilterBarWidget extends StatelessWidget {
  const TaskFilterBarWidget({
    super.key,
    required this.isDark,
    required this.filterStatus,
    required this.taskStatus,
    required this.allTasks,
    required this.onSelectStatus,
  });

  final bool isDark;
  final RxString filterStatus;
  final RxList<TaskStatusLookup> taskStatus;
  final RxList<TaskItem> allTasks;
  final void Function(TaskStatusLookup?) onSelectStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Obx(() {
        final selected = filterStatus.value;
        final statusItems = [null, ...taskStatus];

        final counts = <String, int>{
          'All': allTasks.length,
          for (final s in taskStatus)
            s.name: allTasks
                .where(
                  (t) => t.status.name.toLowerCase() == s.name.toLowerCase(),
                )
                .length,
        };

        return Container(
          padding: kPagePaddingHorizontal,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
            itemCount: statusItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final status = statusItems[i];
              final label = status?.name ?? 'All';
              final isSelected = selected == label;
              final count = counts[label] ?? 0;

              return FilterChipWidget(
                isDark: isDark,
                filter: label,
                count: count,
                selected: isSelected,
                onTap: () => onSelectStatus(status),
              );
            },
          ),
        );
      }),
    );
  }
}
