import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/navigation/notification_icon_with_badge.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/navigation/profile_avatar_widget.dart';
import 'package:task_tracking_mobile/features/employee/data/models/nav_item.dart';

class NavItemWidget extends StatelessWidget {
  const NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final NavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? const Color(0xFF5A5A7A)
        : const Color(0xFFB8B8CC);
    final isNotificationItem = item.icon == Icons.notifications_rounded;
    final isProfileItem = item.icon == Icons.person_rounded;

    Widget iconWidget;
    if (isProfileItem) {
      iconWidget = ProfileAvatarWidget(isSelected: isSelected);
    } else if (isNotificationItem) {
      iconWidget = NotificationIconWithBadge(
        icon: item.icon,
        isSelected: isSelected,
        inactiveColor: inactiveColor,
      );
    } else {
      iconWidget = Icon(
        item.icon,
        size: 21,
        color: isSelected ? Colors.white : inactiveColor,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 14 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7C6FFF), Color(0xFF6C63FF)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: kPrimary.withAlpha(110),
                        blurRadius: 18,
                        spreadRadius: -2,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey('${item.icon}_$isSelected'),
                child: iconWidget,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? kPrimary : inactiveColor,
              letterSpacing: isSelected ? 0.1 : 0,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
