import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_list_card_widget.dart';
import 'package:task_tracking_mobile/features/task/data/models/task_item_model.dart';

// ── List Task Widget ─────────────────────────────────────────
class ListTaskWidget extends StatelessWidget {
  const ListTaskWidget({super.key, required this.isDark, required this.tasks});

  final bool isDark;
  final List<TaskItemModel> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return SliverPadding(
        padding: kPageSectionPadding,
        sliver: SliverToBoxAdapter(child: _EmptyState(isDark: isDark)),
      );
    }

    return SliverPadding(
      padding: kPageSectionPadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => TaskListCard(isDark: isDark, task: tasks[index]),
          childCount: tasks.length,
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 52,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
