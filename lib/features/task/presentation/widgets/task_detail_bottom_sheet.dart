import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/task_detail_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_detail_body_widget.dart';

class TaskDetailBottomSheet extends StatelessWidget {
  const TaskDetailBottomSheet({
    super.key,
    required this.task,
    required this.isDark,
    required this.scrollController,
    required this.ctrl,
  });

  final TaskItem task;
  final bool isDark;
  final ScrollController scrollController;
  final TaskDetailController ctrl;

  static Future<void> show(
    BuildContext context,
    bool isDark,
    TaskItem task, {
    Future<TaskItem?> Function(String id)? fetchDetail,
  }) async {
    TaskItemRepository? repo;
    try {
      repo = Get.find<TaskItemRepository>();
    } catch (_) {}

    final ctrl = Get.put(TaskDetailController(repo, task), tag: task.id);
    if (fetchDetail != null) ctrl.loadFresh(fetchDetail);

    final scrollController = ScrollController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailBottomSheet(
        task: task,
        isDark: isDark,
        scrollController: scrollController,
        ctrl: ctrl,
      ),
    );
    scrollController.dispose();
    Get.delete<TaskDetailController>(tag: task.id, force: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    final textColor = isDark ? Colors.white : kTextDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: keyboardBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.task_rounded,
                    color: kPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => Text(
                      ctrl.task.value.title,
                      style: AppTextStyles.title(
                        color: textColor,
                      ).copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Obx(() {
                  if (!ctrl.isLoadingTask.value) return const SizedBox.shrink();
                  return const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[100],
          ),

          // ── Scrollable body ──────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenH * 0.75),
            child: Obx(() {
              final t = ctrl.task.value;
              return TaskDetailBodyWidget(
                task: t,
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
