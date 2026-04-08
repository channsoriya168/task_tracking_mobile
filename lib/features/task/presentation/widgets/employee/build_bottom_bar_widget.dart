import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/employee/task_sheet_widgets.dart';

class BuildBottomBarWidget extends StatelessWidget {
  const BuildBottomBarWidget({
    super.key,
    required bool hasActions,
    required this.isDark,
    required this.divColor,
    required this.ctrl,
    required bool isPending,
    required this.task,
    required this.context,
  }) : _hasActions = hasActions,
       _isPending = isPending;

  final bool _hasActions;
  final bool isDark;
  final Color divColor;
  final EmployeeTaskController ctrl;
  final bool _isPending;
  final TaskItem task;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    if (!_hasActions) return const SizedBox.shrink();

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? kBgDark : kBgLight,
        border: Border(top: BorderSide(color: divColor)),
      ),
      child: Obx(() {
        final activeId = ctrl.transitionLoadingId.value;

        if (_isPending) {
          return TaskTransitionButton(
            width: double.infinity,
            label: 'task_accept'.tr,
            color: task.allowedTransitions.first.color,
            loading: activeId == -1,
            onTap: () => ctrl.handleAccept(task),
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
                    label: transitions[i].localizedName,
                    color: transitions[i].color,
                    loading: activeId == transitions[i].id,
                    onTap: () => ctrl.handleTransition(task, transitions[i]),
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
                    label: transitions[i].localizedName,
                    color: transitions[i].color,
                    loading: activeId == transitions[i].id,
                    onTap: () => ctrl.handleTransition(task, transitions[i]),
                  ),
                ),
                if (hasNext) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TaskTransitionButton(
                      label: transitions[i + 1].localizedName,
                      color: transitions[i + 1].color,
                      loading: activeId == transitions[i + 1].id,
                      onTap: () =>
                          ctrl.handleTransition(task, transitions[i + 1]),
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
