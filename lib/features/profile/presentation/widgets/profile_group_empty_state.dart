import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class ProfileGroupEmptyState extends StatelessWidget {
  const ProfileGroupEmptyState({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 36,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 8),
            Text(
              'No groups assigned',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
