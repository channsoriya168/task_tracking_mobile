import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

const kDashboardActivity = [
  ('Task assigned to John',        'Engineering', '2 min ago',  Icons.assignment_rounded,   kPrimary),
  ('Jane completed Design task',   'Design',      '15 min ago', Icons.check_circle_rounded, Color(0xFF2ED573)),
  ('New staff member added',       'HR',          '1 hr ago',   Icons.person_add_rounded,   Color(0xFFFFA502)),
  ('Task overdue: API Integration','Engineering', '2 hr ago',   Icons.warning_rounded,      Color(0xFFFF4757)),
  ('Report generated',             'Management',  '5 hr ago',   Icons.bar_chart_rounded,    Color(0xFF6C63FF)),
  ('Meeting scheduled',            'Management',  'Yesterday',  Icons.event_rounded,        Color(0xFFFFA502)),
];

class DashboardActivityCard extends StatelessWidget {
  const DashboardActivityCard({super.key, required this.isDark, required this.index});

  final bool isDark;
  final int index;

  @override
  Widget build(BuildContext context) {
    final (title, tag, time, icon, color) = kDashboardActivity[index];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    Text(time, style: const TextStyle(fontSize: 11, color: kTextMuted)),
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
