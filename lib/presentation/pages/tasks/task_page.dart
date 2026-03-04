import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/data/models/task_model.dart';
import 'package:task_tracking_mobile/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/presentation/widgets/task_card.dart';
import 'package:task_tracking_mobile/presentation/widgets/circular_icon_button.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final themeCtrl = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: kPagePadding,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.space_dashboard_rounded,
                      color: kPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Task List',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  const Spacer(),
                  CircularIconButton(
                    icon: Icons.reply_rounded,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  CircularIconButton(
                    icon: themeCtrl.isDark
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    isDark: isDark,
                    onTap: themeCtrl.toggle,
                  ),
                ],
              ),
            ),

            // ── Filter tabs ───────────────────────────────────
            Padding(
              padding: kPagePadding,
              child: Row(
                children: [
                  _filterTab('Todo', ctrl.todoCount, ctrl, isDark),
                  const SizedBox(width: 8),
                  _filterTab('InProgress', ctrl.inReviewCount, ctrl, isDark),
                  const SizedBox(width: 8),
                  _filterTab('Complete', ctrl.completedTasks, ctrl, isDark),
                ],
              ),
            ),

            // ── Search ────────────────────────────────────────
            Padding(
              padding: kPageSectionPadding,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? kCardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (v) => ctrl.searchQuery.value = v,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(color: kTextMuted, fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: kTextMuted,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ── Task list ─────────────────────────────────────
            Expanded(
              child: ctrl.filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 52,
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks found',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white38 : kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: kPageBottomPadding,
                      itemCount: ctrl.filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = ctrl.filteredTasks[index];
                        final highlighted =
                            task.status == TaskStatus.inProgress && index == 0;
                        return Padding(
                          padding: kItemSpacing,
                          child: TaskCard(
                            task: task,
                            highlighted: highlighted,
                            onToggle: () => ctrl.toggleComplete(task.id),
                            onDelete: () => ctrl.deleteTask(task.id),
                            onTap: () {},
                            onAccept: task.status == TaskStatus.todo
                                ? () => showProgressSheet(context, ctrl, task)
                                : null,
                            onFinish: task.status == TaskStatus.inProgress
                                ? () => showProgressSheet(context, ctrl, task)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Static so HomeShell can call it for the FAB ────────────
  static void showTaskSheet(
    BuildContext context,
    TaskController ctrl,
    TaskModel? existing,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final category = (existing?.category ?? 'General').obs;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  existing == null ? 'New Task' : 'Edit Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 16),
                _field(titleCtrl, 'Title', isDark),
                const SizedBox(height: 12),
                _field(descCtrl, 'Description (optional)', isDark, maxLines: 3),
                const SizedBox(height: 16),
                Text(
                  'Category',
                  style: const TextStyle(fontSize: 13, color: kTextMuted),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category.value,
                  items: kCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) category.value = v;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? kCardDark : kBgLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: kContentPaddingSmall,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                  dropdownColor: isDark ? kCardDark : Colors.white,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;
                      if (existing == null) {
                        ctrl.addTask(
                          TaskModel(
                            id: ctrl.generateId(),
                            title: title,
                            description: descCtrl.text.trim(),
                            category: category.value,
                          ),
                        );
                      } else {
                        ctrl.updateTask(
                          existing.copyWith(
                            title: title,
                            description: descCtrl.text.trim(),
                            category: category.value,
                          ),
                        );
                      }
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      existing == null ? 'Add Task' : 'Save Changes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static void showProgressSheet(
    BuildContext context,
    TaskController ctrl,
    TaskModel task,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final descCtrl = TextEditingController(text: task.description);
    final isAccept = task.status == TaskStatus.todo;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isAccept ? 'Accept Task' : 'Submit Task',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              // Title — read-only
              const Text('Title',
                  style: TextStyle(fontSize: 13, color: kTextMuted)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: kContentPaddingSmall,
                decoration: BoxDecoration(
                  color: isDark ? kCardDark : kBgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category — read-only
              const Text('Category',
                  style: TextStyle(fontSize: 13, color: kTextMuted)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: kContentPaddingSmall,
                decoration: BoxDecoration(
                  color: isDark ? kCardDark : kBgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.category,
                  style: const TextStyle(
                      fontSize: 14, color: kTextMuted),
                ),
              ),
              const SizedBox(height: 12),
              // Progress notes — editable
              const Text('Progress Notes',
                  style: TextStyle(fontSize: 13, color: kTextMuted)),
              const SizedBox(height: 6),
              _field(descCtrl, 'Describe your progress...', isDark,
                  maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final desc = descCtrl.text.trim();
                    if (isAccept) {
                      ctrl.acceptTask(task.id, description: desc);
                    } else {
                      ctrl.finishTask(task.id, description: desc);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAccept
                        ? kPrimary
                        : const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isAccept ? 'Accept Task' : 'Submit Task',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _filterTab(
    String filter,
    int count,
    TaskController ctrl,
    bool isDark,
  ) {
    final selected = ctrl.filterStatus.value == filter;
    final label = filter == 'InProgress' ? 'In Progress' : filter;
    return GestureDetector(
      onTap: () => ctrl.filterStatus.value = filter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: kButtonPaddingSmall,
        decoration: BoxDecoration(
          color: selected ? kTextDark : (isDark ? kCardDark : Colors.white),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white54 : kTextMuted),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: kItemSpacingSmall,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : kPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _field(
    TextEditingController ctrl,
    String hint,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : kTextDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
        filled: true,
        fillColor: isDark ? kCardDark : kBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: kContentPaddingSmall,
      ),
    );
  }
}
