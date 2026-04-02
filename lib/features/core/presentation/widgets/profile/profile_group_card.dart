import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color accent strip
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [groupColor, groupColor.withValues(alpha: 0.4)],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      // Group info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              groupName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : kTextDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (joinedDate != null)
                              Text(
                                'Joined ${joinedDate.day.toString().padLeft(2, '0')}/${joinedDate.month.toString().padLeft(2, '0')}/${joinedDate.year}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : kTextMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Role chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: groupColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: groupColor.withAlpha(60)),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}