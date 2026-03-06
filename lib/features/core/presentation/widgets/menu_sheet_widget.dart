import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class MenuSheetAction {
  const MenuSheetAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
}

class MenuSheetWidget extends StatelessWidget {
  const MenuSheetWidget({
    super.key,
    required this.actions,
    required this.isDark,
    required this.mutedColor,
    this.triggerIcon = Icons.more_horiz_rounded,
    this.triggerSize = 18,
  });
  final List<MenuSheetAction> actions;
  final bool isDark;
  final Color mutedColor;
  final IconData triggerIcon;
  final double triggerSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _show(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(triggerIcon, size: triggerSize, color: mutedColor),
      ),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? kSurfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...actions.map((action) {
              final actionColor =
                  action.color ?? (isDark ? Colors.white70 : kTextDark);
              return ListTile(
                leading: Icon(action.icon, color: actionColor),
                title: Text(action.label, style: TextStyle(color: actionColor)),
                onTap: () {
                  Navigator.pop(context);
                  action.onTap();
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
