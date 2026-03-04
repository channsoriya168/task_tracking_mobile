import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/data/models/task_model.dart';
import 'package:task_tracking_mobile/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/presentation/widgets/stat_card.dart';
import 'package:task_tracking_mobile/presentation/widgets/task_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();
    final themeCtrl = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: SafeArea(
        child: Obx(() => CustomScrollView(
          slivers: [
            // ── Profile Header ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimary, Color(0xFF9B8FFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Greeting + name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : kTextMuted,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Alex Johnson',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Theme toggle
                    GestureDetector(
                      onTap: themeCtrl.toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? kCardDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          color: isDark ? kMediumPriority : kPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── My Tasks title + Add button ──────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Tasks',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : kTextDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${controller.totalTasks} tasks total',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddTaskSheet(context, controller),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Stat Cards ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  childAspectRatio: 1.4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      label: 'Total Tasks',
                      value: '${controller.totalTasks}',
                      icon: Icons.task_alt_rounded,
                      color: kPrimary,
                    ),
                    StatCard(
                      label: 'Completed',
                      value: '${controller.completedTasks}',
                      icon: Icons.check_circle_outline_rounded,
                      color: kLowPriority,
                    ),
                    StatCard(
                      label: 'In Progress',
                      value: '${controller.inProgressTasks}',
                      icon: Icons.timelapse_rounded,
                      color: kMediumPriority,
                    ),
                    StatCard(
                      label: 'High Priority',
                      value: '${controller.highPriorityTasks}',
                      icon: Icons.flag_rounded,
                      color: kHighPriority,
                    ),
                  ],
                ),
              ),
            ),

            // ── Search ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? kCardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: kTextMuted, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
            ),

            // ── Filter Chips ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: ['All', 'Active', 'Done'].map((filter) {
                    final selected = controller.filterStatus.value == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => controller.filterStatus.value = filter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? kPrimary : (isDark ? kCardDark : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : (isDark ? Colors.white54 : kTextMuted),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Progress Bar ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: controller.completionRate,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(controller.completionRate * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Task List ────────────────────────────────────
            controller.filteredTasks.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 52,
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
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
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = controller.filteredTasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TaskCard(
                              task: task,
                              onToggle: () => controller.toggleComplete(task.id),
                              onDelete: () => controller.deleteTask(task.id),
                              onTap: () => _showEditTaskSheet(context, controller, task),
                            ),
                          );
                        },
                        childCount: controller.filteredTasks.length,
                      ),
                    ),
                  ),
          ],
        )),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _showAddTaskSheet(BuildContext context, TaskController controller) {
    _showTaskSheet(context, controller, null);
  }

  void _showEditTaskSheet(BuildContext context, TaskController controller, TaskModel task) {
    _showTaskSheet(context, controller, task);
  }

  void _showTaskSheet(BuildContext context, TaskController controller, TaskModel? existing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priority = (existing?.priority ?? TaskPriority.medium).obs;
    final category = (existing?.category ?? 'General').obs;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? kSurfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Obx(() => SingleChildScrollView(
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
              _sheetField(titleCtrl, 'Title', isDark),
              const SizedBox(height: 12),
              _sheetField(descCtrl, 'Description (optional)', isDark, maxLines: 3),
              const SizedBox(height: 16),
              // Priority
              Text('Priority', style: TextStyle(fontSize: 13, color: kTextMuted)),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final selected = priority.value == p;
                  final color = p == TaskPriority.high
                      ? kHighPriority
                      : p == TaskPriority.medium
                          ? kMediumPriority
                          : kLowPriority;
                  final label = p == TaskPriority.high
                      ? 'High'
                      : p == TaskPriority.medium
                          ? 'Medium'
                          : 'Low';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => priority.value = p,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? color.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? color : (isDark ? Colors.white24 : Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? color : kTextMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Category
              Text('Category', style: TextStyle(fontSize: 13, color: kTextMuted)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category.value,
                items: kCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) { if (v != null) category.value = v; },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? kCardDark : kBgLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      controller.addTask(TaskModel(
                        id: controller.generateId(),
                        title: title,
                        description: descCtrl.text.trim(),
                        priority: priority.value,
                        category: category.value,
                      ));
                    } else {
                      controller.updateTask(existing.copyWith(
                        title: title,
                        description: descCtrl.text.trim(),
                        priority: priority.value,
                        category: category.value,
                      ));
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheetField(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
