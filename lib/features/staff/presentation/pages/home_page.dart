import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/staff/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/staff/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/features/staff/presentation/pages/notification_page.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/features/staff/presentation/widgets/task/list_task_widget.dart';

const _kStatusFilters = ['All', 'Pending', 'In Progress', 'Complete', 'Fail'];

const _kFilterColors = {
  'All': kPrimary,
  'Pending': Color(0xFFFFA502),
  'In Progress': Color(0xFF6C63FF),
  'Complete': Color(0xFF2ED573),
  'Fail': Color(0xFFFF4757),
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Default to showing all tasks on the home screen
    final taskCtrl = Get.find<TaskController>();
    if (!_kStatusFilters.contains(taskCtrl.filterStatus.value)) {
      taskCtrl.filterStatus.value = 'All';
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final taskCtrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? kBgDark : const Color(0xFFF5F5FA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Obx(() {
          final tasks = taskCtrl.filteredTasks;
          final upcoming = taskCtrl.upcomingTasks;
          final pendingCount = taskCtrl.pendingCount;

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

              // ── Progress Card ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _ProgressCard(isDark: isDark, ctrl: taskCtrl),
                ),
              ),

              // ── Due Soon ──────────────────────────────────────────
              if (upcoming.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          'Due Soon',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : kTextDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4757).withAlpha(22),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${upcoming.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF4757),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 96,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      itemCount: upcoming.length,
                      itemBuilder: (_, i) => _UpcomingChip(
                        task: upcoming[i],
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ],

              // ── My Tasks Header ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                ),
              ),

              // ── Filter Chips ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: _kStatusFilters.map((status) {
                        final isSelected =
                            taskCtrl.filterStatus.value == status;
                        final color = _kFilterColors[status] ?? kPrimary;
                        return GestureDetector(
                          onTap: () => taskCtrl.filterStatus.value = status,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color
                                  : (isDark ? kCardDark : Colors.white),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : color.withAlpha(55),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Task List ─────────────────────────────────────────
              ListTaskWidget(isDark: isDark, tasks: tasks),

              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        }),
      ),
    );
  }
}

// ── Progress Card ─────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.isDark, required this.ctrl});

  final bool isDark;
  final TaskController ctrl;

  @override
  Widget build(BuildContext context) {
    final rate = ctrl.completionRate;
    final pct = (rate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withAlpha(70),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 7,
                    backgroundColor: Colors.white.withAlpha(40),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      'done',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withAlpha(180),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall progress',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatItem(label: 'Total', value: '${ctrl.totalTasks}'),
                    _StatDivider(),
                    _StatItem(label: 'Active', value: '${ctrl.inProgressTasks}'),
                    _StatDivider(),
                    _StatItem(label: 'Pending', value: '${ctrl.pendingCount}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withAlpha(160),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: Colors.white.withAlpha(40),
    );
  }
}

// ── Upcoming Task Chip ─────────────────────────────────────────────
class _UpcomingChip extends StatelessWidget {
  const _UpcomingChip({required this.task, required this.isDark});

  final TaskModel task;
  final bool isDark;

  String _timeLabel() {
    if (task.dueDate == null) return '';
    final diff = task.dueDate!.difference(DateTime.now());
    if (diff.inHours < 1) return 'due now';
    if (diff.inHours < 24) return 'in ${diff.inHours}h';
    if (diff.inDays == 1) return 'tomorrow';
    return 'in ${diff.inDays}d';
  }

  Color _priorityColor() => switch (task.priority) {
        TaskPriority.high => const Color(0xFFFF4757),
        TaskPriority.medium => const Color(0xFFFFA502),
        TaskPriority.low => const Color(0xFF2ED573),
      };

  @override
  Widget build(BuildContext context) {
    final accent = _priorityColor();

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Category + time badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? Colors.white38 : kTextMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withAlpha(22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _timeLabel(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          // Title
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : kTextDark,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
