import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class ProfileGroupCard extends StatelessWidget {
  const ProfileGroupCard({
    super.key,
    required this.isDark,
    required this.group,
  });

  final bool isDark;
  final Map<String, dynamic> group;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return kPrimary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return kPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupName = group['groupName'] as String? ?? '—';
    final groupColor = _parseColor(group['groupColor'] as String?);
    final roleMap = group['role'] as Map<String, dynamic>? ?? {};
    final roleName = roleMap['name'] as String? ?? '—';
    final joinedAt = group['joinedAt'] as String?;
    final joinedDate = joinedAt != null ? DateTime.tryParse(joinedAt) : null;
    final joinedStr = joinedDate != null
        ? 'Joined ${joinedDate.day.toString().padLeft(2, '0')}/'
            '${joinedDate.month.toString().padLeft(2, '0')}/'
            '${joinedDate.year}'
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Group info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                if (joinedStr != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    joinedStr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : kTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Role chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: groupColor.withAlpha(isDark ? 40 : 20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roleName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: groupColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
