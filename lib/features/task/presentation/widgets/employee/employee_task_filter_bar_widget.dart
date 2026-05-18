import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/lookup/domain/entities/task_item_status.dart';
import 'package:task_tracking_mobile/core/widgets/filter_chip_widget.dart';

class EmployeeTaskFilterBarWidget extends StatelessWidget {
  const EmployeeTaskFilterBarWidget({
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

        // Exclude "pending" — not relevant for the employee task view.
        final filtered = taskStatus.where(
          (s) => s.name.toLowerCase().replaceAll(' ', '') != 'pending',
        );
        final statusItems = [null, ...filtered];

        final counts = <String, int>{
          'All': allTasks.length,
          for (final s in filtered)
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
              final key = status?.name ?? 'All';
              final displayLabel = status?.localizedName ?? 'status_all'.tr;
              final isSelected = selected == key;
              final count = counts[key] ?? 0;

              return FilterChipWidget(
                isDark: isDark,
                filter: displayLabel,
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
