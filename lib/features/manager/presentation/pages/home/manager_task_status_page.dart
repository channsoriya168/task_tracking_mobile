import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/data/models/task_model.dart';
import 'package:task_tracking_mobile/features/manager/presentation/controllers/manager_task_controller.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/manager_task_card_widget.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/task_dialog_wiget.dart';

class ManagerTaskStatusPage extends StatefulWidget {
  const ManagerTaskStatusPage({super.key, required this.filterStatus});

  /// One of: 'All' | 'Pending' | 'In Progress' | 'Complete' | 'Fail'
  final String filterStatus;

  @override
  State<ManagerTaskStatusPage> createState() => _ManagerTaskStatusPageState();
}

class _ManagerTaskStatusPageState extends State<ManagerTaskStatusPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;

  Color get _statusColor {
    switch (widget.filterStatus) {
      case 'Pending':
        return kMediumPriority;
      case 'In Progress':
        return kPrimary;
      case 'Complete':
        return kLowPriority;
      case 'Fail':
        return kHighPriority;
      default:
        return kPrimary;
    }
  }

  List<TaskModel> _applyFilters(List<TaskModel> all) {
    var result = all.where((t) {
      // Status filter
      switch (widget.filterStatus) {
        case 'Pending':
          if (t.status != TaskStatus.todo) return false;
          break;
        case 'In Progress':
          if (t.status != TaskStatus.inProgress) return false;
          break;
        case 'Complete':
          if (t.status != TaskStatus.done) return false;
          break;
        case 'Fail':
          if (t.status != TaskStatus.fail) return false;
          break;
      }

      // Date filter — match exact day of dueDate
      if (_selectedDate != null) {
        if (t.dueDate == null) return false;
        final d = t.dueDate!;
        final s = _selectedDate!;
        if (d.year != s.year || d.month != s.month || d.day != s.day) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();

    result.sort((a, b) {
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return 0;
    });

    return result;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ManagerTaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _statusColor;
    final textColor = isDark ? Colors.white : kTextDark;
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    final cardBg = isDark ? kCardDark : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(context, isDark),
        backgroundColor: kPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Obx(() {
        final tasks = _applyFilters(ctrl.tasks.toList());

        return CustomScrollView(
          slivers: [
            // ── App Bar ────────────────────────────────────
            SliverAppBar(
              backgroundColor: isDark ? kBgDark : kBgLight,
              floating: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: textColor,
                ),
                onPressed: () => Get.back(),
              ),
              title: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.filterStatus,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Week Calendar ──────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: _WeekCalendar(
                  isDark: isDark,
                  accentColor: color,
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                ),
              ),
            ),

            // ── Search Bar ─────────────────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(fontSize: 14, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Search tasks…',
                      hintStyle: TextStyle(fontSize: 14, color: mutedColor),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: mutedColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Count header ───────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: mutedColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Clear date',
                              style: TextStyle(fontSize: 12, color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Task List ──────────────────────────────────
            tasks.isEmpty
                ? SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks found',
                            style: TextStyle(fontSize: 14, color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ManagerTaskCardWidget(
                            task: tasks[i],
                            managerTaskController: ctrl,
                          ),
                        ),
                        childCount: tasks.length,
                      ),
                    ),
                  ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      }),
    );
  }
}

// ── Week Calendar Widget ───────────────────────────────────────
class _WeekCalendar extends StatefulWidget {
  const _WeekCalendar({
    required this.isDark,
    required this.accentColor,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final bool isDark;
  final Color accentColor;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  @override
  State<_WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<_WeekCalendar> {
  late DateTime _weekStart;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Monday of current week
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  List<DateTime> get _days =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final days = _days;
    final headerMonth = DateFormat('MMMM yyyy').format(_weekStart);
    final cardBg = widget.isDark ? kCardDark : Colors.white;
    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final textColor = widget.isDark ? Colors.white : kTextDark;
    final mutedColor = widget.isDark ? Colors.white38 : kTextMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: month + nav arrows + calendar icon ──
          Row(
            children: [
              Text(
                headerMonth,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const Spacer(),
              _NavBtn(
                icon: Icons.chevron_left_rounded,
                isDark: widget.isDark,
                onTap: () => setState(
                  () =>
                      _weekStart = _weekStart.subtract(const Duration(days: 7)),
                ),
              ),
              const SizedBox(width: 4),
              _NavBtn(
                icon: Icons.chevron_right_rounded,
                isDark: widget.isDark,
                onTap: () => setState(
                  () => _weekStart = _weekStart.add(const Duration(days: 7)),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: widget.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Day name row ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dayNames
                .map(
                  (name) => SizedBox(
                    width: 36,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: mutedColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // ── Date number row ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isSelected =
                  widget.selectedDate != null &&
                  _isSameDay(day, widget.selectedDate!);
              final today = _isToday(day);

              return GestureDetector(
                onTap: () {
                  // tap selected → deselect; else select
                  if (isSelected) {
                    widget.onDateSelected(null);
                  } else {
                    widget.onDateSelected(day);
                  }
                },
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.accentColor
                          : today
                          ? widget.accentColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: today && !isSelected
                          ? Border.all(
                              color: widget.accentColor.withValues(alpha: 0.4),
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || today
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : today
                            ? widget.accentColor
                            : (widget.isDark ? Colors.white70 : kTextDark),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white54 : kTextMuted,
        ),
      ),
    );
  }
}
