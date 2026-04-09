import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_detail_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_body_widget.dart';

class TaskDetailSheetContentWidget extends StatelessWidget {
  const TaskDetailSheetContentWidget({
    super.key,
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
          Obx(
            () => Padding(
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
            ),
          ),

          // ── Scrollable body ──────────────────────────────────
          Expanded(
            child: Obx(() {
              final task = ctrl.task.value;
              return TaskDetailBodyWidget(
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