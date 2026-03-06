import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
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
  DateTime? _selectedDate;

  Future<void> _pickDate(bool isDark) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      builder: (context, child) => Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) {
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
    return '${m[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final taskCtrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: SafeArea(
        child: Obx(() {
          final tasks = taskCtrl.filteredTasks;
          final pendingCount = taskCtrl.pendingCount;

          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────
              SliverAppBar(
                backgroundColor: isDark ? kBgDark : kBgLight,
                actions: [
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
                  Padding(
                    padding: kPagePaddingHorizontal,
                    child: CircularIconButton(
                      isDark: isDark,
                      icon: isDark ? Icons.light_mode : Icons.dark_mode,
                      onTap: () => themeCtrl.toggle(),
                    ),
                  ),
                ],
              ),

              // ── Summary Grid ──────────────────────────────
              SliverPadding(
                padding: kPagePadding,
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    const labels = [
                      'Total',
                      'Pending',
                      'In Progress',
                      'Complete',
                    ];
                    const icons = [
                      Icons.grid_view_rounded,
                      Icons.hourglass_top_rounded,
                      Icons.sync_rounded,
                      Icons.check_circle_outline_rounded,
                    ];
                    const colors = [
                      kPrimary,
                      Color(0xFFFFA502),
                      Color(0xFF6C63FF),
                      Color(0xFF2ED573),
                    ];
                    final counts = [
                      taskCtrl.totalTasks,
                      taskCtrl.pendingCount,
                      taskCtrl.inProgressTasks,
                      taskCtrl.completedTasks,
                    ];
                    return _SummaryCard(
                      isDark: isDark,
                      label: labels[index],
                      count: counts[index],
                      icon: icons[index],
                      color: colors[index],
                    );
                  }, childCount: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.6,
                  ),
                ),
              ),

              // ── Tasks Header + Filters ────────────────────
              SliverPadding(
                padding: kPageSectionLargePadding,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'All Tasks',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          // Date picker
                          GestureDetector(
                            onTap: () => _pickDate(isDark),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedDate != null
                                    ? kPrimary
                                    : (isDark ? kCardDark : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      isDark ? 60 : 12,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 15,
                                    color: _selectedDate != null
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white70
                                              : kTextMuted),
                                  ),
                                  if (_selectedDate != null) ...[
                                    const SizedBox(width: 5),
                                    Text(
                                      _formatDate(_selectedDate!),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedDate = null),
                                      child: const Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Status filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _kStatusFilters.map((status) {
                            final isSelected =
                                taskCtrl.filterStatus.value == status;
                            final color = _kFilterColors[status] ?? kPrimary;
                            return GestureDetector(
                              onTap: () => taskCtrl.filterStatus.value = status,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
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
                                        : color.withAlpha(60),
                                    width: 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: color.withAlpha(60),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : color,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Task List ─────────────────────────────────
              ListTaskWidget(isDark: isDark, tasks: tasks),

              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        }),
      ),
    );
  }
}

// ── Summary Card ────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.isDark,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final bool isDark;
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: kContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : kTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
