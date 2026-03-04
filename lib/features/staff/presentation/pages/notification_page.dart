import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskCtrl = Get.find<TaskController>();

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: SafeArea(
        child: Obx(() {
          final pendingTasks = taskCtrl.pendingTasks;

          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────
              SliverAppBar(
                backgroundColor: isDark ? kBgDark : kBgLight,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? kCardDark : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 60 : 15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark ? Colors.white70 : kTextDark,
                    ),
                  ),
                ),
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4757).withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF4757).withAlpha(80),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${pendingTasks.length} New',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF4757),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Section Header ───────────────────────────────
              SliverPadding(
                padding: kPageSectionLargePadding,
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA502),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'New Task Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Pending Task Cards ───────────────────────────
              if (pendingTasks.isEmpty)
                SliverPadding(
                  padding: kPageSectionPadding,
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 52,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No new notifications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white38 : kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: kPageSectionPadding,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _NotificationCard(
                        isDark: isDark,
                        task: pendingTasks[index],
                        index: index,
                        taskCtrl: taskCtrl,
                      ),
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

// ── Notification Card ───────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.isDark,
    required this.task,
    required this.index,
    required this.taskCtrl,
  });

  final bool isDark;
  final TaskModel task;
  final int index;
  final TaskController taskCtrl;

  String _formatDate(DateTime? d) {
    if (d == null) return 'No date';
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = kPriorityColors[task.priorityLabel] ?? kTextMuted;
    final cardBg = isDark ? kCardDark : Colors.white;
    final titleColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.grey[500]! : kTextMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(80)
                : Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFA502).withAlpha(isDark ? 40 : 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    size: 14,
                    color: Color(0xFFFFA502),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'New task assigned to you',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFA502),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${index + 1}h ago',
                    style: TextStyle(fontSize: 11, color: mutedColor),
                  ),
                ],
              ),
            ),

            // Card body
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + priority
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withAlpha(isDark ? 40 : 20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priorityLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedColor,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 14),

                  // Footer — info row
                  Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 14, color: mutedColor),
                      const SizedBox(width: 4),
                      Text(
                        task.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: mutedColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Due ${_formatDate(task.dueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Footer — action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Decline
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFF4757).withAlpha(120),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF4757),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Accept
                      GestureDetector(
                        onTap: () => taskCtrl.acceptTask(task.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kPrimary, Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimary.withAlpha(80),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Accept',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
