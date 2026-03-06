import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:intl/intl.dart';

// ── Week Calendar ──────────────────────────────────────────────
// _WeekCalendar stays StatefulWidget because _weekStart (navigation state)
// is purely local UI — it does not belong in the business controller.
class WeekCalendarWidget extends StatefulWidget {
  const WeekCalendarWidget({
    required this.isDark,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final bool isDark;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  @override
  State<WeekCalendarWidget> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendarWidget> {
  late DateTime _weekStart;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  List<DateTime> get _days =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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
          // ── Header ────────────────────────────────────────
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
              Icon(Icons.calendar_today_rounded, size: 16, color: kPrimary),
            ],
          ),
          const SizedBox(height: 14),

          // ── Day name row ──────────────────────────────────
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

          // ── Date number row ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isSelected =
                  widget.selectedDate != null &&
                  _isSameDay(day, widget.selectedDate!);
              final isToday = _isSameDay(day, today);

              return GestureDetector(
                onTap: () => widget.onDateSelected(isSelected ? null : day),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimary
                          : isToday
                          ? kPrimary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: kPrimary.withValues(alpha: 0.4))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? kPrimary
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

// ── Nav button ─────────────────────────────────────────────────
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
