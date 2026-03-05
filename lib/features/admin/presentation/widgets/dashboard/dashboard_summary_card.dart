import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

List<(String, int, IconData, Color)> buildDashboardStats(
  int totalTasks,
  int employees,
  int inProgress,
  int complete,
) => [
  ('Total Tasks',      totalTasks,  Icons.grid_view_rounded,           kPrimary),
  ('Total Employees',  employees,   Icons.people_rounded,              const Color(0xFF2ED573)),
  ('In Progress',      inProgress,  Icons.sync_rounded,                const Color(0xFFFFA502)),
  ('Complete',         complete,    Icons.check_circle_outline_rounded, const Color(0xFF00CEC9)),
];

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    super.key,
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
