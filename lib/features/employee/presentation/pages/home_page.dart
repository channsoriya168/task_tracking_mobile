import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/task_chart_widget.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/employee/presentation/pages/notification_page.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/employee/presentation/widgets/task/employee_task_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final taskCtrl = Get.find<EmployeeTaskController>();
    final navCtrl = Get.find<NavigationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? kBgDark : const Color(0xFFF5F5FA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          final allTasks = taskCtrl.allTasks;
          final pendingTasks =
              allTasks.where((t) => t.assignedToName == null).toList();
          final pendingCount = pendingTasks.length;

          return CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white54 : kTextMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Alex Johnson',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : kTextDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          CircularIconButton(
                            icon: Icons.notifications_outlined,
                            isDark: isDark,
                            onTap: () => Get.to(() => const NotificationPage()),
                          ),
                          if (pendingCount > 0)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF4757),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$pendingCount',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      CircularIconButton(
                        isDark: isDark,
                        icon: isDark ? Icons.light_mode : Icons.dark_mode,
                        onTap: () => themeCtrl.toggle(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Task Chart ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TaskChartWidget(
                    isDark: isDark,
                    tasks: taskCtrl.allTasks,
                    taskStatus: taskCtrl.taskStatus,
                  ),
                ),
              ),

              // ── Pending Tasks Header ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Pending Tasks',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                      if (pendingCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA502).withAlpha(22),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFA502),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Task List ─────────────────────────────────────────
              if (taskCtrl.isLoading.value)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (pendingTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
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
                          'No pending tasks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: kPageSectionPadding,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final task = pendingTasks[i];
                        return Padding(
                          padding: kItemSpacing,
                          child: EmployeeTaskCard(
                            task: task,
                            isDark: isDark,
                            onAccept: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Accept Task',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to accept "${task.title}"?',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Accept',
                                        style: TextStyle(
                                          color: kPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                final success = await taskCtrl.acceptTask(task);
                                if (success) {
                                  navCtrl.changePage(1);
                                }
                              }
                            },
                          ),
                        );
                      },
                      childCount: pendingTasks.length,
                    ),
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        }),
      ),
    );
  }
}
